//
//  ResultViewController.swift
//  iOSGame
//
//  Created by Deniz Adil on 3.3.21.
//

import UIKit

class ResultViewController: UIViewController {

    @IBOutlet weak var imageHolderView: UIView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var lblWinner: UILabel!
    @IBOutlet weak var btnsHolderView: UIView!
    @IBOutlet weak var btnHome: UIButton!
    @IBOutlet weak var btnRestartGame: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnBoost: UIButton!
    @IBOutlet weak var lblLooser: UILabel!
    
    var game: Game?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let winner = game?.winner {
            lblWinner.text = winner.username
            let looser = game?.players.filter({ $0.id != winner.id }).first
            lblLooser.text = looser?.username
        }
        
        if let gameController = presentingViewController as? GameViewController {
            gameController.dismiss(animated: true, completion: nil)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func onHome(_ sender: UIButton) {
        
    }
    
    @IBAction func onRestartGame(_ sender: UIButton) {
        
    }
    
    @IBAction func onNext(_ sender: UIButton) {
        
    }
    
    @IBAction func onBoost(_ sender: UIButton) {
        
    }
    
}

