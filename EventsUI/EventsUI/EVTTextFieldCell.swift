//
//  EVTTextFieldCell.swift
//  EventsUI
//
//  Created by Guilherme Rambo on 9/5/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa

public class EVTTextFieldCell: NSTextFieldCell {
    
    override public var backgroundColor: NSColor? {
        get {
            // we need to make sure `backgroundColor` is fully transparent to clear the canvas before drawing our label's text
            return NSColor.clearColor()
        }
        set {}
    }
    
    override public var drawsBackground: Bool {
        get {
            // if `drawsBackground` is false and the color is `labelColor`, there's a drawing glitch
            return true
        }
        set {}
    }
    
    override public func drawWithFrame(cellFrame: NSRect, inView controlView: NSView) {
        guard let ctx = NSGraphicsContext.currentContext()?.CGContext else { return }
        
        CGContextSetBlendMode(ctx, CGBlendMode.Overlay)
        CGContextSetAlpha(ctx, 0.5)
        super.drawWithFrame(cellFrame, inView: controlView)
        
        CGContextSetBlendMode(ctx, CGBlendMode.PlusLighter)
        CGContextSetAlpha(ctx, 1.0)
        super.drawWithFrame(cellFrame, inView: controlView)
    }
    
}
