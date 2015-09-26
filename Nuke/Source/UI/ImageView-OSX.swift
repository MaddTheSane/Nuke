// The MIT License (MIT)
//
// Copyright (c) 2015 Alexander Grebenyuk (github.com/kean).

import Cocoa

public class ImageView: NSImageView {
    public var imageTask: ImageTask?
    public var allowsAnimations = true
    
    deinit {
        self.cancelFetching()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
		imageScaling = .ScaleProportionallyUpOrDown
        //self.contentMode = .ScaleAspectFill
        //self.clipsToBounds = true
    }
    
    public convenience init() {
        self.init(frame: CGRectZero)
    }
    
    public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    public override func prepareForReuse() {
        self.layer?.removeAllAnimations()
        self.image = nil
        self.cancelFetching()
		super.prepareForReuse()
    }
    
    private func cancelFetching() {
        if let task = self.imageTask {
            self.imageTask = nil
            task.cancel()
        }
    }
    
    public func setImageWithURL(URL: NSURL) {
        self.setImageWithRequest(ImageRequest(URL: URL, targetSize: self.targetSize(), contentMode: .AspectFill))
    }
    
    private func targetSize() -> CGSize {
        let size = self.bounds.size
		let scale: CGFloat = 1//UIScreen.mainScreen().scale
        return CGSize(width: size.width * scale, height: size.height * scale)
    }
    
    public func setImageWithRequest(request: ImageRequest) {
        self.cancelFetching()
        let task = Nuke.taskWithRequest(request)
        task.completion { [weak self, weak task] in
            guard let unwrappedTask = task, unwrappedSelf = self where unwrappedTask == unwrappedSelf.imageTask else {
                return
            }
            unwrappedSelf.imageTaskDidFinishWithResponse($0)
        }
        self.imageTask = task
        task.resume()
    }
    
    public func imageTaskDidFinishWithResponse(response: ImageResponse) {
        switch response {
        case let .Success(image, info):
            if self.allowsAnimations && !info.fastResponse && self.image == nil {
                self.image = image
                self.alphaValue = 0.0
				//TODO: OS X port
                //NSView.animateWithDuration(0.25) {
                //    self.alpha = 1.0
                //}
            } else {
                self.image = image
            }
        default: return
        }
    }
}
