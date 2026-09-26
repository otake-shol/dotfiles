// URLからスライド用のQRコードSVGを生成する。macOS標準のCoreImageだけを使う。
// 使い方: swift make-qr.swift <URL> <出力.svg>
import CoreImage
import Foundation

let args = CommandLine.arguments
guard args.count == 3 else {
    FileHandle.standardError.write("usage: swift make-qr.swift <url> <out.svg>\n".data(using: .utf8)!)
    exit(64)
}

guard let filter = CIFilter(name: "CIQRCodeGenerator") else { exit(1) }
filter.setValue(args[1].data(using: .utf8), forKey: "inputMessage")
filter.setValue("M", forKey: "inputCorrectionLevel")
guard let image = filter.outputImage else { exit(1) }

// 1モジュール=1pxで描画し、画素の明暗からモジュールを読み取る
let context = CIContext()
let extent = image.extent.integral
let width = Int(extent.width)
let height = Int(extent.height)
var pixels = [UInt8](repeating: 0, count: width * height * 4)
context.render(image, toBitmap: &pixels, rowBytes: width * 4, bounds: extent,
               format: .RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())

let quiet = 4
let size = width + quiet * 2
var path = ""
for y in 0..<height {
    for x in 0..<width where pixels[(y * width + x) * 4] < 128 {
        path += "M\(x + quiet) \(y + quiet)h1v1h-1z"
    }
}

let svg = """
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 \(size) \(size)" shape-rendering="crispEdges">\
<rect width="\(size)" height="\(size)" fill="#FFFFFF"/><path d="\(path)" fill="#1F1F1F"/></svg>
"""
try svg.write(toFile: args[2], atomically: true, encoding: .utf8)
