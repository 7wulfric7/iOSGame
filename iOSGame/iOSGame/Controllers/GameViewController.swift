//
//  GameViewController.swift
//  iOSGame
//
//  Created by Deniz Adil on 17.2.21.
//

import UIKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var lblGameStatus: UILabel!
    
    var game: Game?
    var opponent: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGameStatusListener()
        
        lblGameStatus.text = game?.state.rawValue
    }
    
    private func setGameStatusListener() {
        guard let game = game else { return }
        DataStore.shared.setGameStateListener(game: game) { [weak self] (updatedGame, error) in
            if let updatedGame = updatedGame {
                self?.updateGame(updatedGame: updatedGame)
            }
        }
    }
    
    private func updateGame(updatedGame: Game) {
        lblGameStatus.text = updatedGame.state.rawValue
        game = updatedGame
        if updatedGame.state == .finished {
            showAlertForGameEnd(title: "Congrats!", message: "You won!")
        }
    }
    
//    func showAlertWith(title: String?, message: String?, isExit: Bool = true) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        let exit = UIAlertAction(title: "Exit", style: .destructive) { [weak self] _ in
//            // we need to update the oher player
//            if let game = self?.game, isExit {
//                DataStore.shared.updateGameStatus(game: game, newState: Game.GameState.finished.rawValue)
//            }
//            self?.dismiss(animated: true, completion: nil)
//        }
//        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        alert.addAction(exit)
//        alert.addAction(cancel)
//        present(alert, animated: true, completion: nil)
//    }
    private func showAlertForExit(title: String?, message: String?) {
            let alert = UIAlertController(title: title,
                                          message: message,
                                          preferredStyle: .alert)
            let exit = UIAlertAction(title: "Exit",
                                     style: .destructive) { [weak self] _ in
                if let game = self?.game {
                    DataStore.shared.updateGameStatus(game: game, newState: Game.GameState.finished.rawValue)
                }
                self?.dismiss(animated: true, completion: nil)
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(exit)
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
        }
        private func showAlertForGameEnd(title: String?, message: String?) {
            let alert = UIAlertController(title: title,
                                          message: message,
                                          preferredStyle: .alert)
            let exit = UIAlertAction(title: "Ok",
                                     style: .destructive) { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            }
            alert.addAction(exit)
            present(alert, animated: true, completion: nil)
        }
    
    @IBAction func onClose(_ sender: UIButton) {
        showAlertForExit(title: nil, message: "Are you sure you want to exit?")
    }
    
}
