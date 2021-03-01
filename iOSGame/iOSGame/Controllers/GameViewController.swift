//
//  GameViewController.swift
//  iOSGame
//
//  Created by Deniz Adil on 17.2.21.
//

import UIKit

class GameViewController: UIViewController {
   
    
    @IBOutlet weak var lblGameStatus: UILabel!
    @IBOutlet weak var btnRandom: UIButton!
    @IBOutlet weak var btnRock: UIButton!
    @IBOutlet weak var btnPaper: UIButton!
    @IBOutlet weak var btnScissors: UIButton!
    
    var game: Game?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGameStatusListener()
        
        lblGameStatus.text = game?.state.rawValue
        lblGameStatus.textColor = .white
        if let game = game {
            // short if statement:
            shouldEnableButtons(enable: game.state == .inprogress)
            // long if statement:
//            if game.state == .inprogress {
//                shouldEnableButtons(enable: true)
//            } else {
//                shouldEnableButtons(enable: false)
//            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
        shouldEnableButtons(enable: (updatedGame.state == .inprogress))
        lblGameStatus.text = updatedGame.state.rawValue
        game = updatedGame
        checkForWinner(game: updatedGame)
        if updatedGame.state == .finished {
            showAlertForGameEnd(title: "Congrats!", message: "You won!")
        }
    }
    
    private func shouldEnableButtons(enable: Bool) {
        btnRock.isEnabled = enable
        btnPaper.isEnabled = enable
        btnScissors.isEnabled = enable
        btnRandom.isEnabled = enable
    }
    
    private func checkForWinner(game: Game) {
        guard let localUserId = DataStore.shared.localUser?.id, let opponentUser = game.players.filter({ $0.id != localUserId }).first, let opponentUserId = opponentUser.id else { return }
        let moves = game.moves
        let myMove = moves[localUserId]
        let otherMove = moves[opponentUserId]
        if myMove == .idle && otherMove == .idle {
            // Both haven't picked a move yet
        } else if myMove == .idle {
            // Still waiting
        } else if otherMove == .idle {
            // Still waiting
        } else {
            // We have both picks
            if let mMove = myMove, let oMove = otherMove {
                if mMove > oMove {
                    // Winner is mMove
                } else {
                    // Winner is oMove
                }
            }
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
    
    @IBAction func onRandom(_ sender: UIButton) {
        guard let localUserId = DataStore.shared.localUser?.id, var game = game else { return }
        //let choices: [Moves] = [.paper, .rock, .scissors] or:
        let choices: [Moves] = Moves.allCases.filter { $0 != .idle }
        let move = choices.randomElement()
        game.moves[localUserId] = move
        DataStore.shared.updateGameMoves(game: game)
        // More Swifty way of doing thing:
//        game.moves[localUserId] = Moves.allCases.filter { $0 != .idle }.randomElements()
    }
    
    @IBAction func onRock(_ sender: UIButton) {
        guard let localUserId = DataStore.shared.localUser?.id, var game = game else { return }
        game.moves[localUserId] = .rock
        DataStore.shared.updateGameMoves(game: game)
    }
    
    @IBAction func onPaper(_ sender: UIButton) {
        guard let localUserId = DataStore.shared.localUser?.id, var game = game else { return }
        game.moves[localUserId] = .paper
        DataStore.shared.updateGameMoves(game: game)
    }
    
    @IBAction func onScissors(_ sender: UIButton) {
        guard let localUserId = DataStore.shared.localUser?.id, var game = game else { return }
        game.moves[localUserId] = .scissors
        DataStore.shared.updateGameMoves(game: game)
    }
    
    
}
