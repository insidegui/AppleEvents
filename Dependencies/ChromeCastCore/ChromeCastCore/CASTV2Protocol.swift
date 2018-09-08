//
//  CASTV2Protocol.swift
//  ChromeCastCore
//
//  Created by Guilherme Rambo on 21/10/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation

enum CastNamespace: String {
    case connection = "urn:x-cast:com.google.cast.tp.connection"
    case heartbeat = "urn:x-cast:com.google.cast.tp.heartbeat"
    case receiver = "urn:x-cast:com.google.cast.receiver"
    case media = "urn:x-cast:com.google.cast.media"
}

enum CastMessageType: String, Codable {
    case ping = "PING"
    case pong = "PONG"
    case connect = "CONNECT"
    case close = "CLOSE"
    case status = "RECEIVER_STATUS"
    case launch = "LAUNCH"
    case stop = "STOP"
    case load = "LOAD"
    case statusRequest = "GET_STATUS"
    case availableApps = "GET_APP_AVAILABILITY"
    case mediaStatus = "MEDIA_STATUS"
}

extension CastMessageType {
    
    var needsRequestId: Bool {
        switch self {
        case .launch, .load, .statusRequest: return true
        default: return false
        }
    }
    
}

struct CastJSONPayloadKeys {
    static let type = "type"
    static let requestId = "requestId"
    static let status = "status"
    static let applications = "applications"
    static let appId = "appId"
    static let displayName = "displayName"
    static let sessionId = "sessionId"
    static let transportId = "transportId"
    static let statusText = "statusText"
    static let isIdleScreen = "isIdleScreen"
    static let namespaces = "namespaces"
    static let volume = "volume"
    static let controlType = "controlType"
    static let level = "level"
    static let muted = "muted"
    static let mediaSessionId = "mediaSessionId"
}

struct CastConstants {
    static let senderName = "sender-0"
    static let receiverName = "receiver-0"
}
