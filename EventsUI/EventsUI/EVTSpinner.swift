//
//  EVTSpinner.swift
//  EventsUI
//
//  Created by Guilherme Rambo on 05/09/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa

public class EVTSpinner: NSProgressIndicator {

    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        configure()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configure()
    }
    
    private func configure() {
        self.appearance = NSAppearance(appearanceNamed: "WhiteSpinner", bundle: NSBundle(forClass: EVTSpinner.self))
        self.indeterminate = true
        self.controlSize = .Regular
    }
    
}
