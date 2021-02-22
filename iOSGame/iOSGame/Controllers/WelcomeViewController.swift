//
//  WelcomeViewController.swift
//  iOSGame
//
//  Created by Deniz Adil on 1.2.21.
//

import UIKit
import FirebaseAuth

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var txtUserName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtUserName.layer.cornerRadius = 10
        txtUserName.layer.masksToBounds = true
        txtUserName.returnKeyType = .continue
        txtUserName.delegate = self
   
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        txtUserName.becomeFirstResponder()
    }
    @IBAction func onContinue(_ sender: UIButton) {
        guard let username = txtUserName.text else { return }
        DataStore.shared.continueWithGuest(username: username) { [weak self] (user, error) in
            guard let self = self else { return }
            if let user = user {
                DataStore.shared.localUser = user
                self.performSegue(withIdentifier: "homeSeque", sender: nil)
            }
        }
    }
    
}

extension WelcomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
