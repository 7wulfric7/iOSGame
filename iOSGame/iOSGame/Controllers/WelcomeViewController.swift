//
//  WelcomeViewController.swift
//  iOSGame
//
//  Created by Deniz Adil on 1.2.21.
//

import UIKit
import FirebaseAuth

class WelcomeViewController: UIViewController {
    
    let avatars = ["avatarOne", "avatarTwo", "avatarThree"]
    var user: User?
//    var opponent: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

   
    }
    
    @IBAction func onContinue(_ sender: UIButton) {
        if Auth.auth().currentUser != nil, let id = Auth.auth().currentUser?.tenantID {
            DataStore.shared.getUserWith(id: id) { [weak self] (user, error) in
                guard let self = self else { return }
                if let user = user {
                    DataStore.shared.localUser = user
                    self.performSegue(withIdentifier: "homeSeque", sender: nil)
                }
            }
            return
        }
        DataStore.shared.continueWithGuest { [weak self] (user, error) in
            guard let self = self else { return }
            if let user = user {
                self.user = user
                self.user?.avatarImage = self.setRandomAvatar()
                DataStore.shared.localUser = self.user
                self.performSegue(withIdentifier: "homeSeque", sender: nil)
            }
        }
    }
    
    func setRandomAvatar() -> String {
        let randomAvatar = Int.random(in: 0...avatars.count - 1)
        let index = randomAvatar
        return avatars[index]
    }
}
