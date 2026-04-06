import Cocoa
import CoreAudio
import ApplicationServices

// =============================================================================
// SpeakerSwap v7 — Aggregate device for L/R swap + Option+Arrow hotkeys for volume
//
// Why aggregate: PreferredChannelsForStereo has zero effect on Audioengine 2+
// Why Option+Arrow: macOS 16 blocks ALL apps from intercepting real volume keys
// =============================================================================

// MARK: - Core Audio

func ca_getString(_ id: AudioObjectID, _ sel: AudioObjectPropertySelector) -> String? {
    var a = AudioObjectPropertyAddress(mSelector: sel, mScope: kAudioObjectPropertyScopeGlobal, mElement: kAudioObjectPropertyElementMain)
    var sz: UInt32 = 0
    guard AudioObjectGetPropertyDataSize(id, &a, 0, nil, &sz) == noErr, sz > 0 else { return nil }
    let b = UnsafeMutableRawPointer.allocate(byteCount: Int(sz), alignment: 8); defer { b.deallocate() }
    guard AudioObjectGetPropertyData(id, &a, 0, nil, &sz, b) == noErr else { return nil }
    return b.load(as: CFString.self) as String
}

func ca_defaultOutput() -> AudioObjectID {
    var id = AudioObjectID(0); var sz = UInt32(MemoryLayout<AudioObjectID>.size)
    var a = AudioObjectPropertyAddress(mSelector: kAudioHardwarePropertyDefaultOutputDevice, mScope: kAudioObjectPropertyScopeGlobal, mElement: kAudioObjectPropertyElementMain)
    AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &a, 0, nil, &sz, &id); return id
}

func ca_setDefaultOutput(_ id: AudioObjectID) {
    var m = id
    var a = AudioObjectPropertyAddress(mSelector: kAudioHardwarePropertyDefaultOutputDevice, mScope: kAudioObjectPropertyScopeGlobal, mElement: kAudioObjectPropertyElementMain)
    AudioObjectSetPropertyData(AudioObjectID(kAudioObjectSystemObject), &a, 0, nil, UInt32(MemoryLayout<AudioObjectID>.size), &m)
}

let kVMVC: AudioObjectPropertySelector = 0x766D7663

// MARK: - Swap Engine

class SwapEngine {
    private(set) var isSwapped = false
    private(set) var realDeviceID: AudioObjectID = 0
    private var aggregateID: AudioObjectID = 0

    var realDeviceName: String {
        ca_getString(realDeviceID != 0 ? realDeviceID : ca_defaultOutput(), kAudioObjectPropertyName) ?? "Unknown"
    }

    // Volume — VirtualMainVolume on the REAL device
    func getVolume() -> Float32 {
        guard realDeviceID != 0 else { return 0.5 }
        var a = AudioObjectPropertyAddress(mSelector: kVMVC, mScope: kAudioObjectPropertyScopeOutput, mElement: kAudioObjectPropertyElementMain)
        if AudioObjectHasProperty(realDeviceID, &a) {
            var v: Float32 = 0; var s = UInt32(MemoryLayout<Float32>.size)
            if AudioObjectGetPropertyData(realDeviceID, &a, 0, nil, &s, &v) == noErr { return v }
        }
        a.mSelector = kAudioDevicePropertyVolumeScalar
        for e: UInt32 in [1, 2, 0] { a.mElement = e
            if AudioObjectHasProperty(realDeviceID, &a) {
                var v: Float32 = 0; var s = UInt32(MemoryLayout<Float32>.size)
                if AudioObjectGetPropertyData(realDeviceID, &a, 0, nil, &s, &v) == noErr { return v }
            }
        }
        return 0.5
    }

    func setVolume(_ vol: Float32) {
        guard realDeviceID != 0 else { return }
        let c = max(0, min(1, vol))
        var a = AudioObjectPropertyAddress(mSelector: kVMVC, mScope: kAudioObjectPropertyScopeOutput, mElement: kAudioObjectPropertyElementMain)
        if AudioObjectHasProperty(realDeviceID, &a) {
            var v = c; AudioObjectSetPropertyData(realDeviceID, &a, 0, nil, UInt32(MemoryLayout<Float32>.size), &v); return
        }
        a.mSelector = kAudioDevicePropertyVolumeScalar
        for e: UInt32 in [1, 2] { a.mElement = e
            if AudioObjectHasProperty(realDeviceID, &a) {
                var v = c; AudioObjectSetPropertyData(realDeviceID, &a, 0, nil, UInt32(MemoryLayout<Float32>.size), &v)
            }
        }
    }

    func toggleMute() {
        guard realDeviceID != 0 else { return }
        var a = AudioObjectPropertyAddress(mSelector: kAudioDevicePropertyMute, mScope: kAudioObjectPropertyScopeOutput, mElement: kAudioObjectPropertyElementMain)
        guard AudioObjectHasProperty(realDeviceID, &a) else { return }
        var m: UInt32 = 0; var s = UInt32(MemoryLayout<UInt32>.size)
        AudioObjectGetPropertyData(realDeviceID, &a, 0, nil, &s, &m)
        m = m == 0 ? 1 : 0
        AudioObjectSetPropertyData(realDeviceID, &a, 0, nil, s, &m)
    }

    // On startup: if a stale aggregate is default, just note it — we'll reuse it in swap()
    func cleanupStale() {
        let curDef = ca_defaultOutput()
        let curUID = ca_getString(curDef, kAudioDevicePropertyDeviceUID) ?? ""
        if curUID == "com.speakerswap.output" {
            NSLog("[SpeakerSwap] Found stale aggregate as default — will reuse on swap")
        }
    }

    // Only works with Audioengine 2+
    let targetDeviceName = "Audioengine 2+"

    /// Find Audioengine 2+ by name, regardless of which device is default
    func findAudioengine() -> (id: AudioObjectID, uid: String)? {
        var ps: UInt32 = 0
        var pa = AudioObjectPropertyAddress(mSelector: kAudioHardwarePropertyDevices, mScope: kAudioObjectPropertyScopeGlobal, mElement: kAudioObjectPropertyElementMain)
        AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &pa, 0, nil, &ps)
        var devs = [AudioObjectID](repeating: 0, count: Int(ps) / MemoryLayout<AudioObjectID>.size)
        AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &pa, 0, nil, &ps, &devs)
        for d in devs {
            let name = ca_getString(d, kAudioObjectPropertyName) ?? ""
            if name == targetDeviceName {
                if let uid = ca_getString(d, kAudioDevicePropertyDeviceUID) { return (d, uid) }
            }
        }
        return nil
    }

    func swap() -> (Bool, String?) {
        guard !isSwapped else { return unswap() }

        // Find Audioengine 2+ by scanning all devices (not just default)
        guard let ae = findAudioengine() else {
            return (false, "\(targetDeviceName) is not connected")
        }
        realDeviceID = ae.id
        let uid = ae.uid

        // Fixed UID so we reuse stale aggregates instead of accumulating them
        let aggUID = "com.speakerswap.output"

        // Check if aggregate with this UID already exists (from a previous crash)
        var ps2: UInt32 = 0
        var pa2 = AudioObjectPropertyAddress(mSelector: kAudioHardwarePropertyDevices, mScope: kAudioObjectPropertyScopeGlobal, mElement: kAudioObjectPropertyElementMain)
        AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &pa2, 0, nil, &ps2)
        var allDevs = [AudioObjectID](repeating: 0, count: Int(ps2) / MemoryLayout<AudioObjectID>.size)
        AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &pa2, 0, nil, &ps2, &allDevs)
        for d in allDevs {
            if ca_getString(d, kAudioDevicePropertyDeviceUID) == aggUID {
                // Reuse existing aggregate
                NSLog("[SpeakerSwap] Reusing existing aggregate ID=%d", d)
                aggregateID = d
                var ch2: [UInt32] = [2, 1]
                var ca2 = AudioObjectPropertyAddress(mSelector: kAudioDevicePropertyPreferredChannelsForStereo, mScope: kAudioObjectPropertyScopeOutput, mElement: kAudioObjectPropertyElementMain)
                AudioObjectSetPropertyData(d, &ca2, 0, nil, UInt32(MemoryLayout<UInt32>.size * 2), &ch2)
                usleep(200_000)
                ca_setDefaultOutput(d)
                usleep(300_000)
                isSwapped = true
                NSLog("[SpeakerSwap] ON (reused) real=%d agg=%d", realDeviceID, d)
                return (true, nil)
            }
        }

        let desc: NSDictionary = [
            kAudioAggregateDeviceUIDKey as String: aggUID,
            kAudioAggregateDeviceNameKey as String: "SpeakerSwap (\(targetDeviceName))",
            kAudioAggregateDeviceSubDeviceListKey as String: [[kAudioSubDeviceUIDKey as String: uid]],
            kAudioAggregateDeviceMainSubDeviceKey as String: uid,
            kAudioAggregateDeviceClockDeviceKey as String: uid,
            kAudioAggregateDeviceIsPrivateKey as String: 0,
            kAudioAggregateDeviceIsStackedKey as String: 0,
        ]
        var agg: AudioObjectID = 0
        let status = AudioHardwareCreateAggregateDevice(desc as CFDictionary, &agg)
        guard status == noErr else {
            NSLog("[SpeakerSwap] Aggregate create failed: %d", status)
            return (false, "Cannot create device (error \(status))")
        }

        // Set swapped channel mapping
        var ch: [UInt32] = [2, 1]; let chSz = UInt32(MemoryLayout<UInt32>.size * 2)
        var ca = AudioObjectPropertyAddress(mSelector: kAudioDevicePropertyPreferredChannelsForStereo, mScope: kAudioObjectPropertyScopeOutput, mElement: kAudioObjectPropertyElementMain)
        AudioObjectSetPropertyData(agg, &ca, 0, nil, chSz, &ch)

        usleep(300_000) // let aggregate fully initialize
        ca_setDefaultOutput(agg)
        usleep(300_000) // let default switch take effect
        // Verify it actually switched
        let curDef = ca_defaultOutput()
        NSLog("[SpeakerSwap] ON  real=%d agg=%d curDefault=%d match=%d", realDeviceID, agg, curDef, curDef == agg ? 1 : 0)
        aggregateID = agg; isSwapped = true
        return (true, nil)
    }

    func unswap() -> (Bool, String?) {
        guard isSwapped else { return (true, nil) }
        if realDeviceID != 0 { ca_setDefaultOutput(realDeviceID) }
        usleep(150_000)
        if aggregateID != 0 { AudioHardwareDestroyAggregateDevice(aggregateID); aggregateID = 0 }
        isSwapped = false; return (true, nil)
    }

    func cleanup() { if isSwapped { _ = unswap() } }
}

// MARK: - Test Tone

class TestTone {
    private var proc: Process?
    func play(_ ch: Int) {
        stop()
        let p = NSTemporaryDirectory() + "ss.wav"
        let sr: UInt32 = 44100; let n: UInt32 = sr + sr / 2; let ds = n * 4; var d = Data()
        func w32(_ v: UInt32) { var x = v.littleEndian; d.append(Data(bytes: &x, count: 4)) }
        func w16(_ v: UInt16) { var x = v.littleEndian; d.append(Data(bytes: &x, count: 2)) }
        d.append(contentsOf: "RIFF".utf8); w32(36 + ds); d.append(contentsOf: "WAVE".utf8)
        d.append(contentsOf: "fmt ".utf8); w32(16); w16(1); w16(2); w32(sr); w32(sr * 4); w16(4); w16(16)
        d.append(contentsOf: "data".utf8); w32(ds)
        for i in 0..<Int(n) {
            let s = Int16(sin(Double(i) * 2.0 * Double.pi * 660.0 / Double(sr)) * 16000)
            var l: Int16 = ch == 0 ? s : 0; var r: Int16 = ch == 1 ? s : 0
            d.append(Data(bytes: &l, count: 2)); d.append(Data(bytes: &r, count: 2))
        }
        try? d.write(to: URL(fileURLWithPath: p))
        let pr = Process(); pr.executableURL = URL(fileURLWithPath: "/usr/bin/afplay"); pr.arguments = [p]
        try? pr.run(); proc = pr
    }
    func stop() { if let p = proc, p.isRunning { p.terminate() }; proc = nil }
}

// MARK: - Volume hotkeys via NSEvent (requires Accessibility permission)

private var _eng: SwapEngine?

func installKeyMonitor() {
    // Request Accessibility if not yet granted
    let opts = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary
    let trusted = AXIsProcessTrustedWithOptions(opts)
    NSLog("[SpeakerSwap] Accessibility: %@", trusted ? "granted" : "not yet — keyboard volume won't work until granted")

    // PageUp=116, PageDown=121
    NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
        guard let e = _eng, e.isSwapped else { return }
        let step: Float32 = 1.0 / 16.0
        switch event.keyCode {
        case 116: e.setVolume(e.getVolume() + step)  // PageUp = volume up
        case 121: e.setVolume(e.getVolume() - step)  // PageDown = volume down
        default: break
        }
    }
    NSLog("[SpeakerSwap] Key monitor: PageUp/PageDown for volume")
}

// MARK: - App Delegate

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private var statusItem: NSStatusItem!
    let engine = SwapEngine()
    private let tone = TestTone()
    private var slider: NSSlider?

    private var deviceListener: AudioObjectPropertyListenerBlock?

    func applicationDidFinishLaunching(_ n: Notification) {
        _eng = engine
        engine.cleanupStale()
        buildMenu()
        installKeyMonitor()
        watchDeviceChanges()
        // Auto-swap if Audioengine 2+ is already the default output
        autoSwapIfAudioengine()
    }

    /// Auto-swap when Audioengine 2+ becomes default, auto-unswap when switching away
    private func watchDeviceChanges() {
        var addr = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain)
        AudioObjectAddPropertyListenerBlock(
            AudioObjectID(kAudioObjectSystemObject), &addr, .main
        ) { [weak self] _, _ in
            guard let self = self else { return }
            let dev = ca_defaultOutput()
            let name = ca_getString(dev, kAudioObjectPropertyName) ?? ""
            // Ignore if we just set our own aggregate as default
            if name.contains("SpeakerSwap") { return }
            if name == self.engine.targetDeviceName && !self.engine.isSwapped {
                // Switched TO Audioengine — auto-swap
                self.doSwap()
            } else if name != self.engine.targetDeviceName && self.engine.isSwapped {
                // Switched AWAY from Audioengine — auto-unswap
                self.doReset()
            }
            self.refreshUI()
        }
    }

    private func autoSwapIfAudioengine() {
        // Auto-swap if Audioengine 2+ is connected (even if not default)
        if engine.findAudioengine() != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in self?.doSwap() }
        }
    }

    func applicationWillTerminate(_ n: Notification) { engine.cleanup(); _eng = nil }

    func menuWillOpen(_ menu: NSMenu) { slider?.floatValue = engine.getVolume() }

    private func buildMenu() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        let m = NSMenu(); m.delegate = self

        let s1 = m.addItem(withTitle: "", action: nil, keyEquivalent: ""); s1.tag = 1; s1.isEnabled = false
        let s2 = m.addItem(withTitle: "", action: nil, keyEquivalent: ""); s2.tag = 2; s2.isEnabled = false
        m.addItem(.separator())

        // Volume
        m.addItem(withTitle: "Volume (Fn+Up / Fn+Down):", action: nil, keyEquivalent: "").isEnabled = false
        let si = NSMenuItem()
        let sv = NSView(frame: NSRect(x: 0, y: 0, width: 240, height: 28))
        let sl = NSSlider(value: 0.5, minValue: 0, maxValue: 1, target: self, action: #selector(slid))
        sl.frame = NSRect(x: 18, y: 4, width: 204, height: 20); sl.isContinuous = true
        sv.addSubview(sl); si.view = sv; m.addItem(si); slider = sl
        let mu = m.addItem(withTitle: "Mute / Unmute (Option+M)", action: #selector(doMute), keyEquivalent: "m"); mu.target = self
        m.addItem(.separator())

        let sw = m.addItem(withTitle: "Swap Left <-> Right", action: #selector(doSwap), keyEquivalent: "s"); sw.target = self; sw.tag = 10
        let rs = m.addItem(withTitle: "Reset to Normal", action: #selector(doReset), keyEquivalent: "r"); rs.target = self
        m.addItem(.separator())

        m.addItem(withTitle: "Test tones:", action: nil, keyEquivalent: "").isEnabled = false
        let tl = m.addItem(withTitle: "Play LEFT channel", action: #selector(doTL), keyEquivalent: ""); tl.target = self
        let tr = m.addItem(withTitle: "Play RIGHT channel", action: #selector(doTR), keyEquivalent: ""); tr.target = self
        m.addItem(.separator())

        let q = m.addItem(withTitle: "Quit SpeakerSwap", action: #selector(doQuit), keyEquivalent: "q"); q.target = self
        statusItem.menu = m; refreshUI()
    }

    private func refreshUI() {
        guard let btn = statusItem?.button, let menu = statusItem?.menu else { return }
        let l = engine.isSwapped ? " R|L " : " L|R "
        let c: NSColor = engine.isSwapped ? .systemOrange : .controlTextColor
        btn.attributedTitle = NSAttributedString(string: l, attributes: [
            .font: NSFont.monospacedSystemFont(ofSize: 13, weight: .bold), .foregroundColor: c])
        menu.item(withTag: 1)?.title = engine.isSwapped ? "Status:  SWAPPED" : "Status:  Normal"
        menu.item(withTag: 2)?.title = "Device:  \(engine.realDeviceName)"
        menu.item(withTag: 10)?.state = engine.isSwapped ? .on : .off
        slider?.floatValue = engine.getVolume()
    }

    @objc private func slid() { if let s = slider { engine.setVolume(s.floatValue) } }
    @objc private func doMute() { engine.toggleMute() }
    @objc private func doSwap() {
        let (ok, err) = engine.swap()
        if !ok { let a = NSAlert(); a.messageText = "Cannot Swap"; a.informativeText = err ?? ""; a.runModal() }
        refreshUI()
    }
    @objc private func doReset() { _ = engine.unswap(); refreshUI() }
    @objc private func doTL() { tone.play(0) }
    @objc private func doTR() { tone.play(1) }
    @objc private func doQuit() { engine.cleanup(); NSApp.terminate(nil) }
}

signal(SIGTERM) { _ in _eng?.cleanup(); exit(0) }
signal(SIGINT) { _ in _eng?.cleanup(); exit(0) }

let app = NSApplication.shared; app.setActivationPolicy(.accessory)
let del = AppDelegate(); app.delegate = del
app.run()
