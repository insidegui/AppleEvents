//
//  EVTMagicImageView.swift
//  EventsUI
//
//  Created by Guilherme Rambo on 05/09/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa
import QuartzCore

public class EVTMagicImageView: NSView {

    public var blurAmountWhenHovered: CGFloat = 40.0
    
    public var blurAmount: CGFloat = 40.0 {
        didSet {
            refreshLayers()
        }
    }
    
    public var image: NSImage? {
        didSet {
            refreshLayers()
        }
    }
    
    public override var frame: NSRect {
        didSet {
            refreshLayers(false)
        }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        commonInit()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        commonInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    private func commonInit() {
        self.wantsLayer = true
        self.layer = CALayer()
        self.layerUsesCoreImageFilters = true
    }
    
    public override var wantsUpdateLayer: Bool {
        return true
    }
    
    private var effectLayer: CALayer!
    private var imageLayer: CALayer!
    
    private var effectFilterChain: [CIFilter] {
        guard let blurFilter = CIFilter(name: "CIGaussianBlur") else { return [] }
        guard let satFilter = CIFilter(name: "CIColorControls") else { return [] }
        
        blurFilter.setDefaults()
        blurFilter.setValue(blurAmount, forKey: "inputRadius")
        
        satFilter.setDefaults()
        satFilter.setValue(1.6, forKey: "inputSaturation")
        
        return [satFilter, blurFilter]
    }
    
    private func refreshLayers(imageChanged: Bool = true, animated: Bool = false) {
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
    
    private var hovering = false {
        didSet {
            guard blurAmountWhenHovered != blurAmount else { return }
            
            refreshLayers(false, animated: true)
        }
    }
    
    private var hoverTrackingArea: NSTrackingArea!
    
    public override func updateTrackingAreas() {
        super.updateTrackingAreas()
        
        if hoverTrackingArea != nil {
            removeTrackingArea(hoverTrackingArea)
        }
        
        hoverTrackingArea = NSTrackingArea(rect: bounds, options: [.ActiveInActiveApp, .MouseEnteredAndExited], owner: self, userInfo: nil)
        addTrackingArea(hoverTrackingArea)
    }
    
    public override func mouseEntered(event: NSEvent) {
        super.mouseEntered(event)
        
        hovering = true
    }
    
    public override func mouseExited(event: NSEvent) {
        super.mouseExited(event)
        
        hovering = false
    }
    
}
