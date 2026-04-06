import Cocoa
import CoreAudio

// =============================================================================
// SpeakerSwap v6 — Direct channel swap on real device. No aggregate device.
// Keyboard volume keys, Sound slider, everything works normally.
// =============================================================================

func ca_defaultOutput() -> AudioObjectID {
    var id = AudioObjectID(0); var sz = UInt32(MemoryLayout<AudioObjectID>.size)
    var a = AudioObjectPropertyAddress(mSelector: kAudioHardwarePropertyDefaultOutputDevice, mScope: kAudioObjectPropertyScopeGlobal, mElement: kAudioObjectPropertyElementMain)
    AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &a, 0, nil, &sz, &id); return id
}

func ca_getName(_ id: AudioObjectID) -> String {
    var a = AudioObjectPropertyAddress(mSelector: kAudioObjectPropertyName, mScope: kAudioObjectPropertyScopeGlobal, mElement: kAudioObjectPropertyElementMain)
    var sz: UInt32 = 0
    guard AudioObjectGetPropertyDataSize(id, &a, 0, nil, &sz) == noErr, sz > 0 else { return "Unknown" }
    let buf = UnsafeMutableRawPointer.allocate(byteCount: Int(sz), alignment: 8); defer { buf.deallocate() }
    guard AudioObjectGetPropertyData(id, &a, 0, nil, &sz, buf) == noErr else { return "Unknown" }
    return buf.load(as: CFString.self) as String
}

func ca_getChannels(_ dev: AudioObjectID) -> [UInt32] {
    var ch: [UInt32] = [1, 2]; var sz = UInt32(MemoryLayout<UInt32>.size * 2)
    var a = AudioObjectPropertyAddress(mSelector: kAudioDevicePropertyPreferredChannelsForStereo, mScope: kAudioObjectPropertyScopeOutput, mElement: kAudioObjectPropertyElementMain)
    AudioObjectGetPropertyData(dev, &a, 0, nil, &sz, &ch); return ch
}

func ca_setChannels(_ dev: AudioObjectID, _ ch: [UInt32]) -> Bool {
    var c = ch; let sz = UInt32(MemoryLayout<UInt32>.size * 2)
    var a = AudioObjectPropertyAddress(mSelector: kAudioDevicePropertyPreferredChannelsForStereo, mScope: kAudioObjectPropertyScopeOutput, mElement: kAudioObjectPropertyElementMain)
    return AudioObjectSetPropertyData(dev, &a, 0, nil, sz, &c) == noErr
}

// MARK: - Swap Engine

class SwapEngine {
    private(set) var isSwapped = false
    private var deviceID: AudioObjectID = 0
    private var originalChannels: [UInt32] = [1, 2]

    var deviceName: String { ca_getName(deviceID != 0 ? deviceID : ca_defaultOutput()) }

    func swap() -> (Bool, String?) {
        guard !isSwapped else { return unswap() }
        deviceID = ca_defaultOutput()
        originalChannels = ca_getChannels(deviceID)
        let swapped: [UInt32] = [originalChannels[1], originalChannels[0]]
        guard ca_setChannels(deviceID, swapped) else { return (false, "Cannot set channels on this device") }
        let verify = ca_getChannels(deviceID)
        guard verify[0] == swapped[0] && verify[1] == swapped[1] else { return (false, "Device rejected channel swap") }
        isSwapped = true
        NSLog("[SpeakerSwap] ON  device=%d channels=[%d,%d]", deviceID, swapped[0], swapped[1])
        return (true, nil)
    }

    func unswap() -> (Bool, String?) {
        guard isSwapped else { return (true, nil) }
        ca_setChannels(deviceID, originalChannels)
        isSwapped = false
        NSLog("[SpeakerSwap] OFF channels=[%d,%d]", originalChannels[0], originalChannels[1])
        return (true, nil)
    }

    func cleanup() { if isSwapped { _ = unswap() } }

    func detectState() {
        deviceID = ca_defaultOutput()
        let ch = ca_getChannels(deviceID)
        isSwapped = ch[0] > ch[1]
        if !isSwapped { originalChannels = ch } else { originalChannels = [ch[1], ch[0]] }
    }
}

// MARK: - Test Tone

class TestTone {
    private var proc: Process?
    func play(_ ch: Int) {
        stop()
        let p = NSTemporaryDirectory() + "ss.wav"; let sr: UInt32 = 44100; let n: UInt32 = sr + sr / 2
        let ds = n * 4; var d = Data()
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

// MARK: - App Delegate

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private var statusItem: NSStatusItem!
    private let engine = SwapEngine()
    private let tone = TestTone()

    func applicationDidFinishLaunching(_ n: Notification) {
        _eng = engine
        engine.detectState()
        buildMenu()
        if CommandLine.arguments.contains("--auto-swap") && !engine.isSwapped {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in self?.doSwap() }
        }
    }
    func applicationWillTerminate(_ n: Notification) { engine.cleanup() }

    func menuWillOpen(_ menu: NSMenu) { refreshUI() }

    private func buildMenu() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        let m = NSMenu(); m.delegate = self
        let s1 = m.addItem(withTitle: "", action: nil, keyEquivalent: ""); s1.tag = 1; s1.isEnabled = false
        let s2 = m.addItem(withTitle: "", action: nil, keyEquivalent: ""); s2.tag = 2; s2.isEnabled = false
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
        menu.item(withTag: 2)?.title = "Device:  \(engine.deviceName)"
        menu.item(withTag: 10)?.state = engine.isSwapped ? .on : .off
    }

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

private var _eng: SwapEngine?
signal(SIGTERM) { _ in _eng?.cleanup(); exit(0) }
signal(SIGINT) { _ in _eng?.cleanup(); exit(0) }

let app = NSApplication.shared; app.setActivationPolicy(.accessory)
let del = AppDelegate(); app.delegate = del
app.run()
