//
//  SplashViewController.swift
//  iOSGame
//
//  Created by Deniz Adil on 22.2.21.
//

import UIKit
import Firebase

class SplashViewController: UIViewController {
    private var user: User?
    override func viewDidLoad() {
        super.viewDidLoad()
        checkForUser()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func checkForUser() {
        if Auth.auth().currentUser != nil, let id = Auth.auth().currentUser?.uid {
            DataStore.shared.getUserWith(id: id) { [weak self] (user, error) in
                if let user = user {
                    DataStore.shared.localUser = user
                    self?.performSegue(withIdentifier: "homeSegue", sender: nil)
                    return
                }
                
                do {
                    try Auth.auth().signOut()
                } catch {
                    print(error.localizedDescription)
                }
            }
        } else {
            performSegue(withIdentifier: "welcomeSegue", sender: nil)
        }
    }
    
    
    
}
