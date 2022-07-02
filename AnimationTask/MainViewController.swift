//
//  MainViewController.swift
//  AnimationTask
//
//  Created by Дмитро  on 22/05/22.
//

import Cocoa

class MainViewController: NSViewController {
    @IBOutlet weak var nextPhotoButton: NSButton!
    @IBOutlet weak var previousPhotoButton: NSButton!
    @IBOutlet weak var layerBackedView: NSView!
    
    var imageLayer: CALayer? {
        willSet {
            imageLayer?.removeFromSuperlayer()
        }
    }
    
    var currentCount = 0 {
        didSet {
            changePhotoWithAnimation()
        }
    }
    
    var images: [NSImage]  {
        var images = [NSImage]()
        for i in 1...6 {
            if let image = NSImage(named: "cat\(i)") {
                images.append(image)
            }
        }
        return images
    }
    
    enum NavigationButtonType {
        case next, previous
    }
    
    var pressedButton: NavigationButtonType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let layerBackedView = layerBackedView, let image = images.first else { return }
        
        let layer = layerForTransitionAnimation(contentImage: image)
        layer.position = CGPoint(x: layerBackedView.bounds.midX, y: layerBackedView.bounds.midY)
        layerBackedView.wantsLayer = true
        layerBackedView.layer?.addSublayer(layer)
        imageLayer = layer
    }
    
    @IBAction func showNextPhoto(_ sender: NSButton) {
        pressedButton = .next

        let lastImageNumber = images.count - 1
        currentCount =  currentCount == lastImageNumber ? 0 : currentCount + 1
    }
    
    @IBAction func showPreviousPhoto(_ sender: NSButton) {
        pressedButton = .previous

        let lastImageNumber = images.count - 1
        currentCount = currentCount == 0 ? lastImageNumber : currentCount - 1
    }
    
    private func changePhotoWithAnimation() {
        guard let layerBackedView = layerBackedView, let imageLayer = imageLayer else  { return }
        
        hideButtonWithAnimation()
        
        let layer = layerForTransitionAnimation(contentImage: images[currentCount])
        layer.transform = CATransform3DMakeScale(0.5, 0.5, 0.5)
        layerBackedView.layer?.addSublayer(layer)
        
        var layerPositionX: CGFloat!
        var positionAnimationX: CGFloat!
        var positionAnimation2X: CGFloat!
        
        switch pressedButton {
        case .next:
        layerPositionX = -layerBackedView.bounds.width - layer.bounds.midX
        
        positionAnimationX = -layerBackedView.bounds.width - layer.bounds.midX // move the central image from center to left
        positionAnimation2X = layerBackedView.bounds.width + layer.bounds.midX // move the next image from right to center

        case .previous:
        layerPositionX = layerBackedView.bounds.width + layer.bounds.midX
        
        positionAnimationX = layerBackedView.bounds.width + layer.bounds.midX // move the central image from center to right
        positionAnimation2X = -layerBackedView.bounds.width - layer.bounds.midX // move the next image from left to center
        case .none:
            break
        }

        layer.position = CGPoint (x: layerPositionX , y: layerBackedView.bounds.midY)
        
        let expandScale = makeTransformAnimation(valueFunctionName: .scale,
                                                  fromValue: [1,1,1],
                                                  toValue: [0.5, 0.5, 0.5])
        
        let position = makePositionAnimation(fromValue: CGPoint(x: layerBackedView.bounds.midX, y: layerBackedView.bounds.midY),
                                             toValue: CGPoint(x: positionAnimationX, y: layerBackedView.bounds.midY),
                                             beginTime: expandScale.beginTime + 2.0)

        let scaleAndPosition = makeAnimationGroup(animation: [expandScale,position],
                                                  duration: 4.0)
        
        
        let position2 = makePositionAnimation(fromValue: CGPoint(x: positionAnimation2X, y: layerBackedView.bounds.midY),
                                              toValue: CGPoint(x: layerBackedView.bounds.midX, y: layerBackedView.bounds.midY),
                                              beginTime: 2.0)
        
        let expandScale2 = makeTransformAnimation(valueFunctionName: .scale,
                                                  fromValue: [0.5,0.5,0.5],
                                                  toValue: [1,1,1],
                                                  beginTime: position2.beginTime + 2.0)
        
        let positionAndScale2 = makeAnimationGroup(animation: [position2,expandScale2],
                                                   duration: 6.0)
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.imageLayer = layer
            self.showButtonWithAnimation()
        }
        
        imageLayer.transform = CATransform3DMakeScale(0.5, 0.5, 0.5)
        imageLayer.add(scaleAndPosition, forKey: nil)
        layer.add(positionAndScale2, forKey: nil)
        CATransaction.commit()
    }
    
    private func hideButtonWithAnimation() {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 2.0
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            nextPhotoButton.animator().alphaValue = 0.0
            previousPhotoButton.animator().alphaValue = 0.0
        }
        nextPhotoButton.isEnabled = false
        previousPhotoButton.isEnabled = false
    }
    
    private func showButtonWithAnimation() {
        self.nextPhotoButton.animator().alphaValue = 1.0
        self.previousPhotoButton.animator().alphaValue = 1.0
        
        self.nextPhotoButton.isEnabled = true
        self.previousPhotoButton.isEnabled = true
    }
    
    private func makePositionAnimation(fromValue:CGPoint, toValue: CGPoint, beginTime: CFTimeInterval, duration: CFTimeInterval = 2.0) -> CABasicAnimation {
        let position = CABasicAnimation(keyPath: "position")
        position.fromValue = fromValue
        position.toValue = toValue
        position.duration = duration
        position.beginTime = beginTime
        position.isRemovedOnCompletion = false
        position.fillMode = .forwards
        
        return position
    }
    
    private func makeTransformAnimation(valueFunctionName: CAValueFunctionName, fromValue: [Double], toValue: [Double], beginTime: CFTimeInterval = 0, duration: CFTimeInterval = 2.0) -> CABasicAnimation {
        let expandScale = CABasicAnimation(keyPath: "transform")
        expandScale.valueFunction = CAValueFunction(name: valueFunctionName)
        expandScale.fromValue = fromValue
        expandScale.toValue = toValue
        expandScale.duration = duration
        expandScale.beginTime = beginTime
        expandScale.isRemovedOnCompletion = false
        expandScale.fillMode = .forwards
        
        return expandScale
    }
    
    private func makeAnimationGroup(animation: [CAAnimation], duration: CFTimeInterval) -> CAAnimationGroup {
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = animation
        animationGroup.duration = 6.0
        animationGroup.isRemovedOnCompletion = false
        animationGroup.fillMode = .forwards
        return animationGroup
    }
    
    private func layerForTransitionAnimation(contentImage: NSImage) -> CALayer {
        let image = contentImage
        let layer = CALayer()
        layer.masksToBounds = true
        layer.contentsGravity = .resizeAspectFill
        
        let newSize = CGSize(width: layerBackedView.bounds.width, height: layerBackedView.bounds.width)
        layer.bounds = CGRect(origin: .zero, size: image.size.sizeByScalingProportionally(to: newSize))
        layer.contents = image
        
        return layer
    }
}

