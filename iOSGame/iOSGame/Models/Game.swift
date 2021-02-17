//
//  Game.swift
//  iOSGame
//
//  Created by Deniz Adil on 17.2.21.
//

import Foundation

struct Game: Codable {
    
    enum GameState: String, Codable {
        case starting
        case inprogress
        case finished
    }
    
    var id: String
    var players: [User]
    var playerIds: [String]
    var winner: User?
    var createdAt: TimeInterval
    var state: GameState
    
    init(id: String, players: [User]) {
        self.id = id
        self.players = players
        //Complact map because we dpn't want "nil" values in the array.
        playerIds = players.compactMap({ $0.id })
//        players = players[0].id! players[1].id!
        //Not in arguments they have the same values for every game which is not yet started
        state = .starting
        createdAt = Date().toMiliseconds()
    }
}
