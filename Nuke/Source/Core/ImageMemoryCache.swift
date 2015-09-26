// The MIT License (MIT)
//
// Copyright (c) 2015 Alexander Grebenyuk (github.com/kean).

#if os(OSX)
	import Cocoa
	#else
	import UIKit
#endif

public protocol ImageMemoryCaching {
    func cachedResponseForKey(key: AnyObject) -> ImageCachedResponse?
    func storeResponse(response: ImageCachedResponse, forKey key: AnyObject)
    func removeAllCachedImages()
}

public class ImageCachedResponse {
    public let image: NukeImage
    public let userInfo: Any?
    
    public init(image: NukeImage, userInfo: Any?) {
        self.image = image
        self.userInfo = userInfo
    }
}

public class ImageMemoryCache: ImageMemoryCaching {
    public let cache: NSCache
    
    deinit {
        #if os(iOS)
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidReceiveMemoryWarningNotification, object: nil)
        #endif
    }
    
    public init(cache: NSCache) {
        self.cache = cache
        #if os(iOS)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("didReceiveMemoryWarning:"), name: UIApplicationDidReceiveMemoryWarningNotification, object: nil)
        #endif
    }
    
    public convenience init() {
        let cache = NSCache()
        cache.totalCostLimit = ImageMemoryCache.recommendedCacheTotalLimit()
        self.init(cache: cache)
    }
    
    public func cachedResponseForKey(key: AnyObject) -> ImageCachedResponse? {
        let object: AnyObject? = self.cache.objectForKey(key)
        return object as? ImageCachedResponse
    }
    
    public func storeResponse(response: ImageCachedResponse, forKey key: AnyObject) {
        let cost = self.costForImage(response.image)
        self.cache.setObject(response, forKey: key, cost: cost)
    }
    
    public func costForImage(image: NukeImage) -> Int {
		#if os(OSX)
			//TODO: OS X port
			//let bits = image.
			return 1
			#else
        let imageRef = image.CGImage
        let bits = CGImageGetWidth(imageRef) * CGImageGetHeight(imageRef) * CGImageGetBitsPerPixel(imageRef)
        return bits / 8
		#endif
    }
    
    public class func recommendedCacheTotalLimit() -> Int {
        #if os(iOS) || os(OSX)
            let physicalMemory = NSProcessInfo.processInfo().physicalMemory
            let ratio = physicalMemory <= (1024 * 1024 * 512 /* 512 Mb */) ? 0.1 : 0.2
            return Int(Double(physicalMemory) * ratio)
        #else
            return 1024 * 1024 * 30 // 30 Mb
        #endif
    }
    
    public func removeAllCachedImages() {
        self.cache.removeAllObjects()
    }
    
    @objc private func didReceiveMemoryWarning(notification: NSNotification) {
        self.cache.removeAllObjects()
    }
}
