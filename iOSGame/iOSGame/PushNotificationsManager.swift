//
//  PushNotificationsManager.swift
//  iOSGame
//
//  Created by Deniz Adil on 10.3.21.
//

import Foundation

class PushNotificationsManager {
    static let shared = PushNotificationsManager()
    private init() {}
    
    private(set) var gameRequest: GameRequest?
    
    func handlePushNotification(dict: [String:Any]) {
        guard let requestId = dict["id"] as? String else { return }
        DataStore.shared.getGameRequestWith(id: requestId) { (request, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.gameRequest = request
        }
    }
    
    func getGameRequest() -> GameRequest? {
//        let request = gameRequest
//        gameRequest = nil
//        return request
        return gameRequest
    }
    
    func clearVariables() {
        gameRequest = nil
    }
}
