//
//  EVTMagicImageView.swift
//  EventsUI
//
//  Created by Guilherme Rambo on 05/09/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa
import QuartzCore

open class EVTMagicImageView: NSView {

    open var blurAmountWhenHovered: CGFloat = 40.0
    
    open var blurAmount: CGFloat = 40.0 {
        didSet {
            refreshLayers()
        }
    }
    
    open var image: NSImage? {
        didSet {
            refreshLayers()
        }
    }
    
    open override var frame: NSRect {
        didSet {
            refreshLayers(false)
        }
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        commonInit()
    }
    
    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        commonInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    fileprivate func commonInit() {
        self.wantsLayer = true
        self.layer = CALayer()
        self.layerUsesCoreImageFilters = true
    }
    
    open override var wantsUpdateLayer: Bool {
        return true
    }
    
    fileprivate var effectLayer: CALayer!
    fileprivate var imageLayer: CALayer!
    
    fileprivate var effectFilterChain: [CIFilter] {
        guard let blurFilter = CIFilter(name: "CIGaussianBlur") else { return [] }
        guard let satFilter = CIFilter(name: "CIColorControls") else { return [] }
        
        blurFilter.setDefaults()
        blurFilter.setValue(blurAmount, forKey: "inputRadius")
        
        satFilter.setDefaults()
        satFilter.setValue(1.6, forKey: "inputSaturation")
        
        return [satFilter, blurFilter]
    }
    
    fileprivate func refreshLayers(_ imageChanged: Bool = true, animated: Bool = false) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(animated ? 0.4 : 0.0)
        CATransaction.setDisableActions(!animated)
        
        if imageLayer == nil {
            effectLayer = CALayer()
            layer?.addSublayer(effectLayer)
            
            imageLayer = CALayer()
            layer?.addSublayer(imageLayer)
        }
        
        let effectiveBlurAmount = hovering ? blurAmount : blurAmountWhenHovered
        let f = effectiveBlurAmount
        effectLayer.frame = CGRect(x: -f/2, y: -f/2, width: bounds.width + f, height: bounds.height + f)
        imageLayer.frame = bounds
        
        if blurAmountWhenHovered != blurAmount {
            effectLayer.opacity = hovering ? 0.7 : 0.3
            imageLayer.frame = hovering ? bounds.insetBy(dx: -10.0, dy: -10.0) : bounds
        } else {
            effectLayer.opacity = 0.7
        }
        
        if imageChanged {
            imageLayer.contents = image
            effectLayer.contents = image
        }
        
        effectLayer.filters = effectFilterChain
        
        CATransaction.commit()
    }
    
    fileprivate var hovering = false {
        didSet {
            guard blurAmountWhenHovered != blurAmount else { return }
            
            refreshLayers(false, animated: true)
        }
    }
    
    fileprivate var hoverTrackingArea: NSTrackingArea!
    
    open override func updateTrackingAreas() {
        super.updateTrackingAreas()
        
        if hoverTrackingArea != nil {
            removeTrackingArea(hoverTrackingArea)
        }
        
        hoverTrackingArea = NSTrackingArea(rect: bounds, options: [.activeInActiveApp, .mouseEnteredAndExited], owner: self, userInfo: nil)
        addTrackingArea(hoverTrackingArea)
    }
    
    open override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        
        hovering = true
    }
    
    open override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        
        hovering = false
    }
    
}
