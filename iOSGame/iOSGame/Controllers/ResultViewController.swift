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
    @IBOutlet weak var btnHome: UIButton!
    @IBOutlet weak var playerOne: UIImageView!
    @IBOutlet weak var playerTwo: UIImageView!
    
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
        } else {
            guard let imageOne = game?.players.first?.avatarImage, let imageTwo = game?.players.last?.avatarImage else { return }
            lblWinner.text = "DRAW! \nTry again"
            playerOne.image = UIImage(named: imageOne)
            playerTwo.image = UIImage(named: imageTwo)
        }
        
    }
    
    @IBAction func onHome(_ sender: UIButton) {
        if let gameController = presentingViewController as? GameViewController {
            dismiss(animated: false) {
                gameController.dismiss(animated: false, completion: nil)
            }
        }
    }
    
}

