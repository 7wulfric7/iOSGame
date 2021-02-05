//
//  GameRequest.swift
//  iOSGame
//
//  Created by Deniz Adil on 3.2.21.
//

import Foundation

struct GameRequest: Codable {
    var id: String
    var from: String // UserdID who inciated the request
    var to: String // UserID who was invited to play
    var createdAt: TimeInterval
    var fromUsername: String?
}
