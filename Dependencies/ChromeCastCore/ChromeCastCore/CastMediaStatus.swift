//
//  CastMediaStatus.swift
//  ChromeCastCore
//
//  Created by Guilherme Rambo on 21/10/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation

public enum CastMediaPlayerState: String, Codable {
    case idle = "IDLE"
    case buffering = "BUFFERING"
    case playing = "PLAYING"
    case paused = "PAUSED"
    case stopped = "STOPPED"
}

final class CastMediaStatusPayload: NSObject, Codable {

    var type: CastMessageType = CastMessageType.mediaStatus
    var requestId: Int?
    var mediaStatus: [CastMediaStatus]?

    enum CodingKeys: String, CodingKey {
        case type
        case requestId
        case mediaStatus = "status"
    }

}

@objcMembers public final class CastMediaStatus: NSObject, Codable {
    
    public var mediaSessionId: Int = 0
    public var playbackRate: Int = 1
    public var playerState: CastMediaPlayerState? = .buffering
    public var currentTime: Double = 0
    
    public var state: String? {
        return playerState?.rawValue
    }
    
    public override var description: String {
        return "MediaStatus(mediaSessionId: \(mediaSessionId), playbackRate: \(playbackRate), playerState: \(String(describing: playerState)), currentTime: \(currentTime))"
    }

    public enum CodingKeys: String, CodingKey {
        case mediaSessionId
        case playbackRate
        case playerState
        case currentTime
    }
    
}
