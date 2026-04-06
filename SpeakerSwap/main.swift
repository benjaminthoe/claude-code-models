import Cocoa
import CoreAudio
import Carbon

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

    // Cleanup stale aggregates
    func cleanupStale() {
        var ps: UInt32 = 0
        var pa = AudioObjectPropertyAddress(mSelector: kAudioHardwarePropertyDevices, mScope: kAudioObjectPropertyScopeGlobal, mElement: kAudioObjectPropertyElementMain)
        AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &pa, 0, nil, &ps)
        var devs = [AudioObjectID](repeating: 0, count: Int(ps) / MemoryLayout<AudioObjectID>.size)
        AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &pa, 0, nil, &ps, &devs)
        let curDef = ca_defaultOutput()
        for d in devs {
            let uid = ca_getString(d, kAudioDevicePropertyDeviceUID) ?? ""
            guard uid.contains("speakerswap") else { continue }
            if d == curDef {
                for d2 in devs where d2 != d {
                    let u2 = ca_getString(d2, kAudioDevicePropertyDeviceUID) ?? ""
                    guard !u2.contains("speakerswap") else { continue }
                    var sa = AudioObjectPropertyAddress(mSelector: kAudioDevicePropertyStreams, mScope: kAudioObjectPropertyScopeOutput, mElement: kAudioObjectPropertyElementMain)
                    var ss: UInt32 = 0; AudioObjectGetPropertyDataSize(d2, &sa, 0, nil, &ss)
                    guard ss > 0 else { continue }
                    let nm = ca_getString(d2, kAudioObjectPropertyName) ?? ""
                    if nm.contains("Virtual") || nm.contains("Teams") || nm.contains("WeMeet") { continue }
                    ca_setDefaultOutput(d2); usleep(200_000); break
                }
            }
            AudioHardwareDestroyAggregateDevice(d)
        }
    }

    // Swap via aggregate device
    func swap() -> (Bool, String?) {
        guard !isSwapped else { return unswap() }
        realDeviceID = ca_defaultOutput()
        guard let uid = ca_getString(realDeviceID, kAudioDevicePropertyDeviceUID) else { return (false, "No UID") }
        let name = realDeviceName
        let desc: NSDictionary = [
            kAudioAggregateDeviceUIDKey as String: "com.speakerswap.\(ProcessInfo.processInfo.processIdentifier)",
            kAudioAggregateDeviceNameKey as String: "SpeakerSwap (\(name))",
            kAudioAggregateDeviceSubDeviceListKey as String: [[kAudioSubDeviceUIDKey as String: uid]],
            kAudioAggregateDeviceMainSubDeviceKey as String: uid,
            kAudioAggregateDeviceClockDeviceKey as String: uid,
            kAudioAggregateDeviceIsPrivateKey as String: 0,
            kAudioAggregateDeviceIsStackedKey as String: 0,
        ]
        var agg: AudioObjectID = 0
        guard AudioHardwareCreateAggregateDevice(desc as CFDictionary, &agg) == noErr else { return (false, "Cannot create device") }

        // Set swapped channel mapping
        var ch: [UInt32] = [2, 1]; let chSz = UInt32(MemoryLayout<UInt32>.size * 2)
        var ca = AudioObjectPropertyAddress(mSelector: kAudioDevicePropertyPreferredChannelsForStereo, mScope: kAudioObjectPropertyScopeOutput, mElement: kAudioObjectPropertyElementMain)
        AudioObjectSetPropertyData(agg, &ca, 0, nil, chSz, &ch)

        ca_setDefaultOutput(agg)
        aggregateID = agg; isSwapped = true
        NSLog("[SpeakerSwap] ON  real=%d agg=%d", realDeviceID, agg)
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

// MARK: - Global Hotkeys (Carbon) — Option+Up/Down/M for volume

private var _eng: SwapEngine?

// Carbon event handler
private func hotkeyHandler(_ nextHandler: EventHandlerCallRef?, _ event: EventRef?, _ userData: UnsafeMutableRawPointer?) -> OSStatus {
    guard let e = _eng, e.isSwapped else { return noErr }
    var hotKeyID = EventHotKeyID()
    GetEventParameter(event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID),
                      nil, MemoryLayout<EventHotKeyID>.size, nil, &hotKeyID)
    let step: Float32 = 1.0 / 16.0
    switch hotKeyID.id {
    case 1: e.setVolume(e.getVolume() + step)  // Option+Up = volume up
    case 2: e.setVolume(e.getVolume() - step)  // Option+Down = volume down
    case 3: e.toggleMute()                      // Option+M = mute
    default: break
    }
    return noErr
}

func installHotkeys() {
    let sig = OSType(0x53535753) // 'SSWS'
    var spec = EventTypeSpec(eventClass: UInt32(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
    var handler: EventHandlerRef?
    InstallEventHandler(GetApplicationEventTarget(), hotkeyHandler, 1, &spec, nil, &handler)

    let optionKey = UInt32(optionKey)
    var ref1: EventHotKeyRef?; var ref2: EventHotKeyRef?; var ref3: EventHotKeyRef?
    RegisterEventHotKey(UInt32(kVK_UpArrow), optionKey, EventHotKeyID(signature: sig, id: 1), GetApplicationEventTarget(), 0, &ref1)
    RegisterEventHotKey(UInt32(kVK_DownArrow), optionKey, EventHotKeyID(signature: sig, id: 2), GetApplicationEventTarget(), 0, &ref2)
    RegisterEventHotKey(UInt32(kVK_ANSI_M), optionKey, EventHotKeyID(signature: sig, id: 3), GetApplicationEventTarget(), 0, &ref3)
    NSLog("[SpeakerSwap] Hotkeys: Option+Up/Down/M for volume")
}

// MARK: - App Delegate

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private var statusItem: NSStatusItem!
    let engine = SwapEngine()
    private let tone = TestTone()
    private var slider: NSSlider?

    func applicationDidFinishLaunching(_ n: Notification) {
        _eng = engine
        engine.cleanupStale()
        buildMenu()
        installHotkeys()
        if CommandLine.arguments.contains("--auto-swap") {
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
        m.addItem(withTitle: "Volume (Option+Up/Down):", action: nil, keyEquivalent: "").isEnabled = false
        let si = NSMenuItem()
        let sv = NSView(frame: NSRect(x: 0, y: 0, width: 240, height: 28))
        let sl = NSSlider(value: 0.5, minValue: 0, maxValue: 1, target: self, action: #selector(slid))
        sl.frame = NSRect(x: 18, y: 4, width: 204, height: 20); sl.isContinuous = true
        sv.addSubview(sl); si.view = sv; m.addItem(si); slider = sl
        let mu = m.addItem(withTitle: "Mute / Unmute (Option+M)", action: #selector(doMute), keyEquivalent: ""); mu.target = self
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
