//
//  User.swift
//  iOSGame
//
//  Created by Deniz Adil on 1.2.21.
//

import Foundation

struct User: Codable {
    var id: String?
    var username: String?
    
    init(id: String, username: String) {
        self.id = id
        self.username = username
    }
    
}
