//
//  EVTTextFieldCell.swift
//  EventsUI
//
//  Created by Guilherme Rambo on 9/5/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa

open class EVTTextFieldCell: NSTextFieldCell {
    
    override open var backgroundColor: NSColor? {
        get {
            // we need to make sure `backgroundColor` is fully transparent to clear the canvas before drawing our label's text
            return NSColor.clear
        }
        set {}
    }
    
    override open var drawsBackground: Bool {
        get {
            // if `drawsBackground` is false and the color is `labelColor`, there's a drawing glitch
            return true
        }
        set {}
    }
    
    override open func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        guard let ctx = NSGraphicsContext.current()?.cgContext else { return }
        
        ctx.setBlendMode(CGBlendMode.overlay)
        ctx.setAlpha(0.5)
        super.draw(withFrame: cellFrame, in: controlView)
        
        ctx.setBlendMode(CGBlendMode.plusLighter)
        ctx.setAlpha(1.0)
        super.draw(withFrame: cellFrame, in: controlView)
    }
    
}
