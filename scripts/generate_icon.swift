import AppKit

let size = CGSize(width: 1024, height: 1024)
let image = NSImage(size: size)

image.lockFocus()

// 1. Draw Background
let ctx = NSGraphicsContext.current!.cgContext
let bgRect = CGRect(origin: .zero, size: size)
// For macOS icons, a slight corner radius is standard, but the OS masks the .icns anyway.
// We'll draw a solid rounded rect just in case.
let bgPath = NSBezierPath(roundedRect: bgRect, xRadius: 225, yRadius: 225)
NSColor(red: 0.04, green: 0.04, blue: 0.05, alpha: 1.0).setFill()
bgPath.fill()

// 2. Prepare the SF Symbol
let config = NSImage.SymbolConfiguration(pointSize: 600, weight: .semibold)
// Modern palette: Vibrant Cyan and Indigo
let colorConfig = NSImage.SymbolConfiguration(paletteColors: [NSColor.systemCyan, NSColor.systemIndigo])
let finalConfig = config.applying(colorConfig)

if let symbol = NSImage(systemSymbolName: "fan.fill", accessibilityDescription: nil)?.withSymbolConfiguration(finalConfig) {
    
    // Setup shadow for glow effect
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.systemCyan.withAlphaComponent(0.6)
    shadow.shadowBlurRadius = 45
    shadow.shadowOffset = .zero
    shadow.set()
    
    // Calculate centered drawing rect
    let symbolSize = symbol.size
    let x = (size.width - symbolSize.width) / 2
    let y = (size.height - symbolSize.height) / 2
    let drawRect = CGRect(origin: CGPoint(x: x, y: y), size: symbolSize)
    
    // Draw symbol
    symbol.draw(in: drawRect)
} else {
    print("Error: Could not load SF Symbol 'fan.fill'")
}

image.unlockFocus()

// 3. Export to PNG
if let tiffData = image.tiffRepresentation,
   let bitmapImage = NSBitmapImageRep(data: tiffData),
   let pngData = bitmapImage.representation(using: .png, properties: [:]) {
    let url = URL(fileURLWithPath: "app_icon.png")
    do {
        try pngData.write(to: url)
        print("Successfully generated app_icon.png")
    } catch {
        print("Error writing file: \(error)")
    }
}
