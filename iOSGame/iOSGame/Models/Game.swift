//
//  Game.swift
//  iOSGame
//
//  Created by Deniz Adil on 17.2.21.
//

import Foundation

enum Moves: String, Comparable, Codable, CaseIterable {
    case idle
    case rock
    case paper
    case scissors
    
    static func < (lhs: Moves, rhs: Moves) -> Bool {
        switch (lhs, rhs) {
        case (.rock, .paper):
            return true
        case (.paper, .scissors):
            return true
        case (.scissors, .rock):
            return true
        case (.idle, .paper):
            return true
        case (.idle, .rock):
            return true
        case (.idle, .scissors):
            return true
        default:
            return false
        }
    }
    
    static func == (lhs: Moves, rhs: Moves) -> Bool {
        switch (lhs, rhs) {
        case (.rock, .rock):
            return true
        case (.paper, .paper):
            return true
        case (.scissors, .scissors):
            return true
        case (.idle, .idle):
            return true
        default:
            return false
        }
    }
}


struct Game: Codable {
    enum GameState: String, Codable {
        case starting
        case inprogress
        case finished
    }
    var id: String
    var players: [User]
    
    var moves = [String:Moves]()
    
    var playerIds: [String]
    var winner: User?
    var createdAt: TimeInterval
    var state: GameState
    
    init(id: String, players: [User], moves: [String:Moves]) {
        self.id = id
        self.players = players
        self.moves = moves
        //Complact map because we dpn't want "nil" values in the array.
        playerIds = players.compactMap({ $0.id })
        //        players = players[0].id! players[1].id!
        //Not in arguments they have the same values for every game which is not yet started
        state = .starting
        createdAt = Date().toMiliseconds()
    }
}
