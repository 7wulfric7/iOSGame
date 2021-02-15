//
//  User.swift
//  iOSGame
//
//  Created by Deniz Adil on 1.2.21.
//

import Foundation

let avatars = ["avatarOne", "avatarTwo", "avatarThree"]

struct User: Codable {
    var id: String?
    var username: String?
    var avatarImage: String?
    var deviceToken: String?
    
//    init(id: String, username: String, avatarImage: String) {
//        self.id = id
//        self.username = username
//        self.avatarImage = avatarImage
//    }
    static func createUser(id: String, username: String) -> User {
        var user = User()
        user.id = id
        user.username = username
        user.avatarImage = avatars.randomElement()
        return user
    }
    
    mutating func setRandomImage() {
        self.avatarImage = avatars.randomElement()
    }
}
