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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func showErrorAlert(username: String) {
        let alert = UIAlertController(title: "Error", message: "\(username) already in use. Please enter another username", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(confirm)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onContinue(_ sender: UIButton) {
        guard let username = txtUserName.text?.lowercased() else { return }
        DataStore.shared.checkForExistingUsername(username) { [weak self] (exists, _) in
            if exists {
                self?.showErrorAlert(username: username)
                return
            }
            DataStore.shared.continueWithGuest(username: username) { [weak self] (user, error) in
                guard let self = self else { return }
                if let user = user {
                    DataStore.shared.localUser = user
                    self.performSegue(withIdentifier: "homeSeque", sender: nil)
                }
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
