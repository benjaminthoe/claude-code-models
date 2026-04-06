import Cocoa

// Generate a 1024x1024 app icon for SpeakerSwap
let size: CGFloat = 1024
let image = NSImage(size: NSSize(width: size, height: size))

image.lockFocus()
guard let ctx = NSGraphicsContext.current?.cgContext else {
    print("ERROR: Cannot get graphics context")
    exit(1)
}

// -- Background: rounded square with gradient --
let bgRect = CGRect(x: 0, y: 0, width: size, height: size)
let cornerRadius: CGFloat = 220
let bgPath = CGPath(roundedRect: bgRect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)

// Deep blue to teal gradient
let colors = [
    CGColor(red: 0.08, green: 0.08, blue: 0.32, alpha: 1.0),
    CGColor(red: 0.00, green: 0.45, blue: 0.55, alpha: 1.0),
]
let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: [0.0, 1.0])!

ctx.saveGState()
ctx.addPath(bgPath)
ctx.clip()
ctx.drawLinearGradient(gradient, start: CGPoint(x: 0, y: size), end: CGPoint(x: size, y: 0), options: [])
ctx.restoreGState()

// -- Subtle inner shadow / border --
ctx.saveGState()
ctx.addPath(bgPath)
ctx.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.15))
ctx.setLineWidth(6)
ctx.strokePath()
ctx.restoreGState()

// -- Draw "L" on left side --
let letterFont = NSFont.systemFont(ofSize: 320, weight: .heavy)
let letterAttrs: [NSAttributedString.Key: Any] = [
    .font: letterFont,
    .foregroundColor: NSColor.white,
]
let lStr = NSAttributedString(string: "L", attributes: letterAttrs)
let lSize = lStr.size()
lStr.draw(at: NSPoint(x: 100, y: (size - lSize.height) / 2 - 20))

// -- Draw "R" on right side --
let rStr = NSAttributedString(string: "R", attributes: letterAttrs)
let rSize = rStr.size()
rStr.draw(at: NSPoint(x: size - rSize.width - 100, y: (size - rSize.height) / 2 - 20))

// -- Draw swap arrows in the middle --
let arrowY = size / 2
let arrowLeft: CGFloat = 320
let arrowRight: CGFloat = size - 320
let arrowGap: CGFloat = 30
let headLen: CGFloat = 35
let lineWidth: CGFloat = 12

// Semi-transparent white for arrows
let arrowColor = CGColor(red: 1, green: 1, blue: 1, alpha: 0.9)
ctx.setStrokeColor(arrowColor)
ctx.setFillColor(arrowColor)
ctx.setLineWidth(lineWidth)
ctx.setLineCap(.round)
ctx.setLineJoin(.round)

// Top arrow: pointing right (L -> R)
let topY = arrowY + arrowGap + 25
ctx.move(to: CGPoint(x: arrowLeft, y: topY))
ctx.addLine(to: CGPoint(x: arrowRight, y: topY))
ctx.strokePath()
// Arrowhead right
ctx.move(to: CGPoint(x: arrowRight - headLen, y: topY + headLen))
ctx.addLine(to: CGPoint(x: arrowRight, y: topY))
ctx.addLine(to: CGPoint(x: arrowRight - headLen, y: topY - headLen))
ctx.strokePath()

// Bottom arrow: pointing left (R -> L)
let botY = arrowY - arrowGap - 25
ctx.move(to: CGPoint(x: arrowRight, y: botY))
ctx.addLine(to: CGPoint(x: arrowLeft, y: botY))
ctx.strokePath()
// Arrowhead left
ctx.move(to: CGPoint(x: arrowLeft + headLen, y: botY + headLen))
ctx.addLine(to: CGPoint(x: arrowLeft, y: botY))
ctx.addLine(to: CGPoint(x: arrowLeft + headLen, y: botY - headLen))
ctx.strokePath()

// -- Small label at bottom --
let labelFont = NSFont.systemFont(ofSize: 80, weight: .medium)
let labelAttrs: [NSAttributedString.Key: Any] = [
    .font: labelFont,
    .foregroundColor: NSColor(white: 1, alpha: 0.6),
]
let label = NSAttributedString(string: "SpeakerSwap", attributes: labelAttrs)
let labelSize = label.size()
label.draw(at: NSPoint(x: (size - labelSize.width) / 2, y: 80))

image.unlockFocus()

// -- Save as PNG --
guard let tiffData = image.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiffData),
      let pngData = bitmap.representation(using: .png, properties: [:])
else {
    print("ERROR: Cannot create PNG data")
    exit(1)
}

let outputDir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "."
let pngPath = "\(outputDir)/icon_1024.png"
try! pngData.write(to: URL(fileURLWithPath: pngPath))
print("Icon saved: \(pngPath)")
