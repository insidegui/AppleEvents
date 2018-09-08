//
//  CastDevice.swift
//  ChromeCastCore
//
//  Created by Guilherme Rambo on 19/10/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation

@objcMembers public final class CastDevice: NSObject, NSCopying {
    
    public private(set) var id: String
    public private(set) var name: String
    public private(set) var hostName: String
    public private(set) var address: Data
    public private(set) var port: Int
    
    init(id: String, name: String, hostName: String, address: Data, port: Int) {
        self.id = id
        self.name = name
        self.hostName = hostName
        self.address = address
        self.port = port
        
        super.init()
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        return CastDevice(id: self.id, name: self.name, hostName: self.hostName, address: self.address, port: self.port)
    }
    
    public override var description: String {
        return "CastDevice(id: \(id), name: \(name), hostName:\(hostName), address:\(address), port:\(port))"
    }
    
}
