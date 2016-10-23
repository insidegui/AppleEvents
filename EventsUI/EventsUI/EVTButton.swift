//
//  EVTButton.swift
//  EventsUI
//
//  Created by Guilherme Rambo on 9/5/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa

open class EVTButton: NSControl {

    fileprivate var widthConstraint: NSLayoutConstraint!
    
    open var title: String = "" {
        didSet {
            sizeToFit()
            configureLayers()
        }
    }
    
    fileprivate var attributedTitle: NSAttributedString {
        let pStyle = NSMutableParagraphStyle()
        pStyle.alignment = .center
        
        let attrs = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
            NSParagraphStyleAttributeName: pStyle
        ] as [String : Any]
        
        return NSAttributedString(string: title, attributes: attrs)
    }
    
    open var textFont: NSFont = NSFont.systemFont(ofSize: 18.0, weight: NSFontWeightMedium) {
        didSet {
            guard titleLayer != nil else { return }
            
            titleLayer.string = attributedTitle
        }
    }
    
    open var textColor: NSColor = NSColor(calibratedWhite: 1.0, alpha: 0.8) {
        didSet {
            guard titleLayer != nil else { return }
            
            titleLayer.string = attributedTitle
        }
    }
    
    fileprivate var titleLayer: CATextLayer!
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        wantsLayer = true
        layer = CALayer()
        
        layer?.backgroundColor = NSColor(calibratedWhite: 1.0, alpha: 0.4).cgColor
        layer?.cornerRadius = 6.0
        layer?.masksToBounds = true
        layer?.compositingFilter = "overlayBlendMode"
        
        configureLayers()
    }
    
    open override var wantsUpdateLayer: Bool {
        return true
    }
    
    open override var intrinsicContentSize: NSSize {
        let ts = attributedTitle.size()
        return NSSize(width: ts.width + 40.0, height: ts.height + 20.0)
    }
    
    open override func sizeToFit() {
        if widthConstraint == nil {
            widthConstraint = self.widthAnchor.constraint(equalToConstant: intrinsicContentSize.width)
        }
        widthConstraint.constant = intrinsicContentSize.width
        widthConstraint.isActive = true
        superview?.layoutSubtreeIfNeeded()
    }
    
    fileprivate var isMouseDown = false
    
    fileprivate var shouldDisplayHighlightedState = false {
        didSet {
            if shouldDisplayHighlightedState {
                layer?.backgroundColor = NSColor(calibratedWhite: 1.0, alpha: 0.7).cgColor
            } else {
                layer?.backgroundColor = NSColor(calibratedWhite: 1.0, alpha: 0.4).cgColor
            }
        }
    }
    
    open override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        
        isMouseDown = true
        shouldDisplayHighlightedState = true
        
        while(isMouseDown) {
            guard let event = NSApp.nextEvent(matching: [.leftMouseUp, .leftMouseDragged], until: Date.distantFuture, inMode: RunLoopMode.eventTrackingRunLoopMode, dequeue: true) else { continue }
            
            let point = self.convert(event.locationInWindow, to: self)
            
            switch event.type {
            case .leftMouseUp:
                isMouseDown = false
                self.shouldDisplayHighlightedState = false
                
                if hitTest(point) == self {
                    NSApplication.shared().sendAction(action!, to: target, from: self)
                }
            case .leftMouseDragged:
                shouldDisplayHighlightedState = (hitTest(point) == self)
            default: break
            }
        }
        
    }
    
    fileprivate func configureLayers() {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0)
        
        if titleLayer == nil {
            titleLayer = CATextLayer()
            titleLayer.contentsScale = NSScreen.main()?.backingScaleFactor ?? 1.0
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
