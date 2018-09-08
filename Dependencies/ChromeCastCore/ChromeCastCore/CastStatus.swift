//
//  CastStatus.swift
//  ChromeCastCore
//
//  Created by Guilherme Rambo on 21/10/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation

public final class CastVolume: NSObject, Codable {

    public var level: Double = 0
    public var muted: Bool = false

    public init(level: Double = 1, muted: Bool = false) {
        self.level = level
        self.muted = muted
    }

}

@objcMembers final class CastStatusPayload: NSObject, Codable {

    var type: CastMessageType = CastMessageType.status
    var requestId: Int?
    var status: CastStatus?

    enum CodingKeys: String, CodingKey {
        case type
        case requestId
        case status
    }

}

public final class CastStatus: NSObject, Codable {
    
    public var volume: CastVolume = CastVolume()
    public var apps: [CastApp]?
    
    public override var description: String {
        return """
               CastStatus(volume: \(volume.level),
                          muted: \(volume.muted),
                          apps: \(String(describing: apps))
               """
    }

    public enum CodingKeys: String, CodingKey {
        case volume
        case apps = "applications"
    }
    
}
