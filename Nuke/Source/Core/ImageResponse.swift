// The MIT License (MIT)
//
// Copyright (c) 2015 Alexander Grebenyuk (github.com/kean).

#if os(OSX)
	import Cocoa
	public typealias NukeImage = NSImage
#else
	import UIKit
	public typealias NukeImage = UIImage
#endif

public enum ImageResponse {
    case Success(NukeImage, ImageResponseInfo)
    case Failure(ErrorType)

    public var image: NukeImage? {
        switch self {
        case let .Success(image, _): return image
        case .Failure(_): return nil
        }
    }
}

public class ImageResponseInfo {
    public let fastResponse: Bool
    public let userInfo: Any?

    public init(fastResponse: Bool, userInfo: Any? = nil) {
        self.fastResponse = fastResponse
        self.userInfo = userInfo
    }
}
