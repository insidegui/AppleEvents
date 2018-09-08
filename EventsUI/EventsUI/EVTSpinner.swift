//
//  EVTSpinner.swift
//  EventsUI
//
//  Created by Guilherme Rambo on 05/09/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa

open class EVTSpinner: NSProgressIndicator {

    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        configure()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configure()
    }
    
    fileprivate func configure() {
        self.appearance = NSAppearance(appearanceNamed: NSAppearance.Name(rawValue: "WhiteSpinner"), bundle: Bundle(for: EVTSpinner.self))
        self.isIndeterminate = true
        self.controlSize = .regular
    }
    
}
