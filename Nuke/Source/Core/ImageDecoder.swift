// The MIT License (MIT)
//
// Copyright (c) 2015 Alexander Grebenyuk (github.com/kean).

#if os(OSX)
	import Cocoa
	#else
	import UIKit
#endif
#if os(watchOS)
import WatchKit
#endif

public protocol ImageDecoding {
    func imageWithData(data: NSData) -> NukeImage?
}

public class ImageDecoder: ImageDecoding {
    public init() {}
    public func imageWithData(data: NSData) -> NukeImage? {
        #if os(iOS)
            return UIImage(data: data, scale: UIScreen.mainScreen().scale)
        #elseif os(watchOS)
            return UIImage(data: data, scale: WKInterfaceDevice.currentDevice().screenScale)
		#elseif os(OSX)
			//TODO: scaling info
			return NSImage(data: data)
		#else
			fatalError("Unknown Architecture")
			return nil
        #endif
    }
}

public class ImageDecoderComposition: ImageDecoding {
    let decoders: [ImageDecoding]
    
    public init(decoders: [ImageDecoding]) {
        self.decoders = decoders
    }
    
    public func imageWithData(data: NSData) -> NukeImage? {
        for decoder in self.decoders {
            if let image = decoder.imageWithData(data) {
                return image
            }
        }
        return nil
    }
}
