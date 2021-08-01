    import XCTest
    import MobileCoreServices
    import ImageIO
    @testable import exif

    final class exifTests: XCTestCase {
      let fileManager = FileManager()
      
      func testWrite() {
        let url = URL(string: "https://user-images.githubusercontent.com/8779423/111466775-f9d4a580-8723-11eb-8846-7522e41765cd.jpg")!
        guard let imageData = try? Data(contentsOf: url) else {
          XCTFail()
          return
        }
        
        let sourceURL = fileManager.temporaryDirectory.appendingPathComponent("exifTestOriginal.jpg")
        let destinationURL = fileManager.temporaryDirectory.appendingPathComponent("exifTestEdited.jpg")
        try? imageData.write(to: sourceURL, options: .atomic)

        
        guard let outputImage = CGImageDestinationCreateWithURL(destinationURL as CFURL, kUTTypeJPEG, 1, nil) else {
          fatalError()
        }
        
        guard let imageSource = CGImageSourceCreateWithURL(sourceURL as CFURL, nil) else {
          fatalError()
        }
        
        var properties: [NSString: AnyObject] = [:]
        let newTime = "2020:11:22 22:11:00"
         properties[kCGImagePropertyExifDictionary] = [kCGImagePropertyExifDateTimeOriginal: newTime] as CFDictionary
        
        CGImageDestinationAddImageFromSource(outputImage, imageSource, 0, properties as CFDictionary)
        CGImageDestinationFinalize(outputImage)
        
        let editedImageData = try! Data(contentsOf: destinationURL)
        let editedCIImage =  CIImage(data: editedImageData)!
        let props = editedCIImage.properties["{Exif}"] as? [String: Any]
        let editedDateTime = props![kCGImagePropertyExifDateTimeOriginal as String] as! String
        XCTAssert(editedDateTime == newTime)
      }
    }
