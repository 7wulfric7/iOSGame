//
//  DataSTore+GameRequests.swift
//  iOSGame
//
//  Created by Deniz Adil on 3.2.21.
//

import Foundation

extension DataStore {
    
    func startGameRequest(userID: String, completion: @escaping (_ request: GameRequest?, _ error: Error?) -> Void) {
        let requestRef = database.collection(FirebaseCollections.gameRequests.rawValue).document()
        let gameRequest = createGameRequest(toUser: userID, id: requestRef.documentID)
        do {
            try requestRef.setData(from: gameRequest, completion: { error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                completion(gameRequest, nil)
            })
        } catch {
            completion(nil, error)
        }
    }
    private func createGameRequest(toUser: String, id: String) -> GameRequest? {
        guard let localUserId = localUser?.id else { return nil }
        return GameRequest(id: id,
                           from: localUserId,
                           to: toUser,
                           createdAt: Date().toMiliseconds(),
                           fromUsername: localUser?.username)
    }
    
    func checkForExtistingGameRequest(toUser: String, fromUser: String, completion: @escaping(_ exists: Bool, _ error: Error?) -> Void ) {
        let gameRequestRef = database.collection(FirebaseCollections.gameRequests.rawValue)
            .whereField("from", isEqualTo: fromUser)
            .whereField("to", isEqualTo: toUser)
        gameRequestRef.getDocuments { (snapshot, error) in
            if let error = error {
                completion(false, error)
                return
            }
            if let snapshot = snapshot, snapshot.documents.count > 0 {
                completion(true, nil)
                return
            }
            completion(false, nil)
        }
    }
    
    func setGameRequestListener() {
        if gameRequestListener != nil {
            removeGameRequestListener()
        }
        guard let localUserId = localUser?.id else { return }
        gameRequestListener = database
            .collection(FirebaseCollections.gameRequests.rawValue)
            .whereField("to", isEqualTo: localUserId)
            .addSnapshotListener({ (snapshot, error) in
                if let snapshot = snapshot, let document = snapshot.documents.first {
                    do {
                        let gameRequest = try document.data(as: GameRequest.self)
                        NotificationCenter.default.post(name: Notification.Name("DidReceiveGameRequestNotification"), object: nil, userInfo: ["GameRequest":gameRequest as Any])
                        print("New GameRequest With " + (gameRequest?.from ?? ""))
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            })
    }
    
    func removeGameRequestListener() {
        gameRequestListener?.remove()
        gameRequestListener = nil
    }
    
    func setGameRequestDeletionListener(completion: @escaping () -> Void) {
        if gameRequestDeletionListener != nil {
            removeGameRequestDeletionListener()
        }
        guard let localUserId = localUser?.id else { return }
        gameRequestDeletionListener = database
            .collection(FirebaseCollections.gameRequests.rawValue)
            .whereField("from", isEqualTo: localUserId)
            .addSnapshotListener { (snapshot, error) in
                completion()
            }
    }
    
    func removeGameRequestDeletionListener() {
        gameRequestDeletionListener?.remove()
        gameRequestDeletionListener = nil
    }
    
    func deleteGameRequest(gameRequest: GameRequest) {
        let gameRequestRef = database.collection(FirebaseCollections.gameRequests.rawValue).document(gameRequest.id)
        gameRequestRef.delete()
    }
}
