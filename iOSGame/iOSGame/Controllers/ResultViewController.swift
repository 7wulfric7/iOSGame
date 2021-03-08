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
    
    var game: Game?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        showWinnerLooserInfo()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private func showWinnerLooserInfo() {
        if let winner = game?.winner {
            guard let winnerImage = winner.avatarImage,
                  let winnerPlayer = winner.username,
                  let looser = game?.players.filter({ $0.id != winner.id }).first,
                  let looserPlayer = looser.username
            else {return}
            lblWinner.text = "\(winnerPlayer) WINS! \n\(looserPlayer) LOOSES!"
            userImage.image = UIImage(named: winnerImage)
        }
    }
    
    @IBAction func onHome(_ sender: UIButton) {
        if let gameController = presentingViewController as? GameViewController {
            gameController.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func onRestartGame(_ sender: UIButton) {
        
    }
    
    @IBAction func onNext(_ sender: UIButton) {
        
    }
    
    @IBAction func onBoost(_ sender: UIButton) {
        
    }
    
}

