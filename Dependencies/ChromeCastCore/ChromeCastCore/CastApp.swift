//
//  CastApp.swift
//  ChromeCastCore
//
//  Created by Guilherme Rambo on 21/10/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation

public enum CastAppIdentifier: String {
    case defaultMediaPlayer = "CC1AD845"
    case youTube = "YouTube"
}

@objcMembers public final class CastApp: NSObject, Codable {
    
    public var id: String = ""
    public var displayName: String = ""
    public var isIdleScreen: Bool = false
    public var sessionId: String = ""
    public var statusText: String = ""
    public var transportId: String = ""

    public enum CodingKeys: String, CodingKey {
        case id = "appId"
        case displayName
        case isIdleScreen
        case sessionId
        case statusText
        case transportId
    }

    public override var description: String {
        return """
               CastApp(id: \(id),
                       displayName:\(displayName),
                       isIdleScreen: \(isIdleScreen),
                       sessionId:\(sessionId),
                       statusText:\(statusText),
                       transportId:\(transportId))
               """
    }
    
}
