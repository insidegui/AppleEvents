//
//  EVTButton.swift
//  EventsUI
//
//  Created by Guilherme Rambo on 9/5/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa

public class EVTButton: NSControl {

    private var widthConstraint: NSLayoutConstraint!
    
    public var title: String = "" {
        didSet {
            sizeToFit()
            configureLayers()
        }
    }
    
    private var attributedTitle: NSAttributedString {
        let pStyle = NSMutableParagraphStyle()
        pStyle.alignment = .Center
        
        let attrs = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
            NSParagraphStyleAttributeName: pStyle
        ]
        
        return NSAttributedString(string: title, attributes: attrs)
    }
    
    public var textFont: NSFont = NSFont.systemFontOfSize(18.0, weight: NSFontWeightMedium) {
        didSet {
            guard titleLayer != nil else { return }
            
            titleLayer.string = attributedTitle
        }
    }
    
    public var textColor: NSColor = NSColor(calibratedWhite: 1.0, alpha: 0.8) {
        didSet {
            guard titleLayer != nil else { return }
            
            titleLayer.string = attributedTitle
        }
    }
    
    private var titleLayer: CATextLayer!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        wantsLayer = true
        layer = CALayer()
        
        layer?.backgroundColor = NSColor(calibratedWhite: 1.0, alpha: 0.4).CGColor
        layer?.cornerRadius = 6.0
        layer?.masksToBounds = true
        layer?.compositingFilter = "overlayBlendMode"
        
        configureLayers()
    }
    
    public override var wantsUpdateLayer: Bool {
        return true
    }
    
    public override var intrinsicContentSize: NSSize {
        let ts = attributedTitle.size()
        return NSSize(width: ts.width + 40.0, height: ts.height + 20.0)
    }
    
    public override func sizeToFit() {
        if widthConstraint == nil {
            widthConstraint = self.widthAnchor.constraintEqualToConstant(intrinsicContentSize.width)
        }
        widthConstraint.constant = intrinsicContentSize.width
        widthConstraint.active = true
        superview?.layoutSubtreeIfNeeded()
    }
    
    private var isMouseDown = false
    
    private var shouldDisplayHighlightedState = false {
        didSet {
            if shouldDisplayHighlightedState {
                layer?.backgroundColor = NSColor(calibratedWhite: 1.0, alpha: 0.7).CGColor
            } else {
                layer?.backgroundColor = NSColor(calibratedWhite: 1.0, alpha: 0.4).CGColor
            }
        }
    }
    
    public override func mouseDown(event: NSEvent) {
        super.mouseDown(event)
        
        isMouseDown = true
        shouldDisplayHighlightedState = true
        
        while(isMouseDown) {
            guard let event = NSApp.nextEventMatchingMask([.LeftMouseUp, .LeftMouseDragged], untilDate: NSDate.distantFuture(), inMode: NSEventTrackingRunLoopMode, dequeue: true) else { continue }
            
            let point = self.convertPoint(event.locationInWindow, toView: self)
            
            switch event.type {
            case .LeftMouseUp:
                isMouseDown = false
                self.shouldDisplayHighlightedState = false
                
                if hitTest(point) == self {
                    NSApplication.sharedApplication().sendAction(action, to: target, from: self)
                }
            case .LeftMouseDragged:
                shouldDisplayHighlightedState = (hitTest(point) == self)
            default: break
            }
        }
        
    }
    
    private func configureLayers() {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0)
        
        if titleLayer == nil {
            titleLayer = CATextLayer()
            titleLayer.contentsScale = NSScreen.mainScreen()?.backingScaleFactor ?? 1.0
            titleLayer.compositingFilter = "overlayBlendMode"
            titleLayer.alignmentMode = kCAAlignmentCenter
            layer?.addSublayer(titleLayer)
        }
        
        let ts = self.attributedTitle.size()
        
        titleLayer.frame = CGRect(
            x: 0,
            y: bounds.height / 2.0 - ts.height / 2.0,
            width: bounds.width,
            height: ts.height
        )
        
        titleLayer.string = self.attributedTitle
        
        CATransaction.commit()
    }
    
}
