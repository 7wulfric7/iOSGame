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
    @IBOutlet weak var opponentHandImage: UIImageView!
    @IBOutlet weak var myHandImage: UIImageView!
    @IBOutlet weak var lblFight: UILabel!
    @IBOutlet weak var myHandButtomConstraint: NSLayoutConstraint!
    @IBOutlet weak var opponentTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bloodImage: UIImageView!
    @IBOutlet weak var myHandHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var opponentHeightConstraint: NSLayoutConstraint!
    
    var game: Game?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bloodImage.transform = CGAffineTransform(scaleX: 0, y: 0)
        setConstraintsForSmallerDevice()
        setGameStatusListener()
        lblGameStatus.text = game?.state.rawValue
        lblGameStatus.textColor = .white
        lblFight.text = "FIGHT"
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
    
    private func setConstraintsForSmallerDevice() {
        // 420 Height for iPhone X
        if DeviceType.isIphone8OrSmaller {
            myHandHeightConstraint.constant = 320
            opponentHeightConstraint.constant = 320
        } else if DeviceType.isIphoneXOrBigger {
            myHandHeightConstraint.constant = 420
            opponentHeightConstraint.constant = 420
        }
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
        animateMoves(game: updatedGame)
        //        return
        checkForWinner(game: updatedGame)
        if updatedGame.state == .finished && game?.winner == nil {
            DataStore.shared.removeGameListener()
            game?.winner = updatedGame.players.filter({ $0.id == DataStore.shared.localUser?.id}).first
            //            showAlertForGameEnd(title: "Congrats!", message: "You won!")
            continueToResults()
        }
    }
    
    private func shouldEnableButtons(enable: Bool) {
        btnRock.isEnabled = enable
        btnPaper.isEnabled = enable
        btnScissors.isEnabled = enable
        btnRandom.isEnabled = enable
    }
    
    private func animateMoves(game: Game) {
        guard let localUserId = DataStore.shared.localUser?.id, let opponentUser = game.players.filter({ $0.id != localUserId }).first, let opponentUserId = opponentUser.id else { return }
        let moves = game.moves
        let myMove = moves[localUserId]
        let otherMove = moves[opponentUserId]
        if myMove != .idle && otherMove != .idle {
            animateHandTo(move: myMove, isMyHand: true)
            animateHandTo(move: otherMove, isMyHand: false)
            // We will animate both hands at the same time back on board
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.myHandButtomConstraint.constant = Moves.minimumY(isOpponent: false)
                self.opponentTopConstraint.constant = Moves.minimumY(isOpponent: true)
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                } completion: { finished in
                    if finished {
                        self.checkForWinner(game: game)
                    }
                    // Homework
                    // Winner hand should go little further and animate blood beneath
                }
            }
            return
        }
    }
    
    private func animateHandTo(move: Moves?, isMyHand: Bool) {
        guard let move = move, move != .idle else {return}
        if isMyHand {
            myHandButtomConstraint.constant = Moves.maximumY
        } else {
            opponentTopConstraint.constant = Moves.maximumY
        }
        UIView.animate(withDuration: 0.3) {
            // closure for animation
            self.view.layoutIfNeeded()
        } completion: { finished in
            // closure for when the animation is done, finished flag argument (flag == bool)
            if finished {
                if isMyHand {
                    self.myHandImage.image = UIImage(named: move.imageName(isOpponent: !isMyHand))
                } else {
                    self.opponentHandImage.image = UIImage(named: move.imageName(isOpponent: true))
                }
            }
        }
    }
    //    private func animateMyHandTo(move: Moves?) {
    //        guard let move = move, move != .idle else {return}
    //        myHandButtomConstraint.constant = Moves.maximumY
    //        UIView.animate(withDuration: 0.3) {
    //            // closure for animation
    //            self.view.layoutIfNeeded()
    //        } completion: { finished in
    //            // closure for when the animation is done, finished flag argument (flag == bool)
    //            if finished {
    //                self.myHandImage.image = UIImage(named: move.imageName(isOpponent: false))
    //            }
    //        }
    //    }
    //
    //    private func animateOtherHandTo(move: Moves?) {
    //        guard let move = move, move != .idle else {return}
    //        opponentTopConstraint.constant = Moves.maximumY
    //        UIView.animate(withDuration: 0.3) {
    //            // closure for animation
    //            self.view.layoutIfNeeded()
    //        } completion: { finished in
    //            // closure for when the animation is done, finished flag argument (flag == bool)
    //            if finished {
    //                self.opponentHandImage.image = UIImage(named: move.imageName(isOpponent: true))
    //            }
    //        }
    //    }
    
    private func animateFinalMoves(animatingImageView: UIImageView, space: CGFloat, game: Game) {
        UIView.animate(withDuration: 0.5) {
            animatingImageView.transform = CGAffineTransform(translationX: 0, y: space)
        } completion: { (finished) in
            if finished {
                UIView.animate(withDuration: 0.5) {
                    self.bloodImage.transform = .identity
                    animatingImageView.transform = .identity
                } completion: { (finished) in
                    if finished {
                        if animatingImageView == self.myHandImage {
                        self.setWinner(game: game)
                        } else {
                            if self.game != nil {
                                self.continueToResults()
                            }
                        }
                    }
                }
            }
        }
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
            // We have both picked
            if let mMove = myMove, let oMove = otherMove {
                // This if will succeed only if local user is winner, the other user will get listener for the game with updated property
                let space = abs((opponentHandImage.frame.origin.y + opponentHandImage.frame.height) - myHandImage.frame.origin.y)
                if mMove > oMove {
                    // Winner is mMove
                    // Animating winner hand to kick the looser
                    //space between the hands images
                    animateFinalMoves(animatingImageView: myHandImage, space: -space, game: game)
                }
                if mMove < oMove {
                    animateFinalMoves(animatingImageView: opponentHandImage, space: space, game: game)
                } else {
                    DataStore.shared.removeGameListener()
                    self.game?.state = .finished
                    DataStore.shared.updateGameMoves(game: self.game!)
                    self.game?.winner = nil
                    self.continueToResults()
                }
            }
        }
    }
    
    private func setWinner(game: Game) {
        guard let localUserId = DataStore.shared.localUser?.id else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            DataStore.shared.removeGameListener()
            self.game?.winner = game.players.filter({ $0.id == localUserId }).first
            self.game?.state = .finished
            DataStore.shared.updateGameMoves(game: self.game!)
            self.continueToResults()
        }
    }
    
    private func continueToResults() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) { [self] in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "ResultViewController") as! ResultViewController
            controller.game = game
            self.navigationController?.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true, completion: nil)
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
        //        sender.isSelected = true
        //        makeSelectedMove()
        let choices: [Moves] = Moves.allCases.filter { $0 != .idle }
        guard let move = choices.randomElement() else {return}
        selsectButtonForMove(move: move)
        pickedMove(move)
        lblFight.text = ""
        bloodImage.image = UIImage(named: "VersuS")
    }
    
    @IBAction func onRock(_ sender: UIButton) {
        sender.isSelected = true
        //        makeSelectedMove()
        pickedMove(.rock)
        lblFight.text = ""
        bloodImage.image = UIImage(named: "VersuS")
    }
    
    @IBAction func onPaper(_ sender: UIButton) {
        sender.isSelected = true
        //        makeSelectedMove()
        pickedMove(.paper)
        lblFight.text = ""
        bloodImage.image = UIImage(named: "VersuS")
    }
    
    @IBAction func onScissors(_ sender: UIButton) {
        sender.isSelected = true
        //        makeSelectedMove()
        pickedMove(.scissors)
        lblFight.text = ""
        bloodImage.image = UIImage(named: "VersuS")
    }
    
    private func selsectButtonForMove(move: Moves) {
        switch move {
        case .idle:
            return
        case .rock:
            btnRock.isSelected = true
        case .paper:
            btnPaper.isSelected = true
        case .scissors:
            btnScissors.isSelected = true
        }
    }
    
    private func pickedMove(_ move: Moves) {
        guard let localUserId = DataStore.shared.localUser?.id, var game = game else { return }
        game.moves[localUserId] = move
        DataStore.shared.updateGameMoves(game: game)
        shouldEnableButtons(enable: false)
    }
    
    //    private func makeSelectedMove() {
    //        guard let localUserId = DataStore.shared.localUser?.id, var game = game else { return }
    //        //let choices: [Moves] = [.paper, .rock, .scissors] or:
    //        let choices: [Moves] = Moves.allCases.filter { $0 != .idle }
    //        let move = choices.randomElement()
    //        // More Swifty way of doing thing:
    ////        game.moves[localUserId] = Moves.allCases.filter { $0 != .idle }.randomElements()
    //        if btnRock.isSelected {
    //            game.moves[localUserId] = .rock
    //        } else if btnPaper.isSelected {
    //            game.moves[localUserId] = .paper
    //        } else if btnScissors.isSelected {
    //            game.moves[localUserId] = .scissors
    //        } else if btnRandom.isSelected {
    //            game.moves[localUserId] = move
    //        } else { return }
    //        DataStore.shared.updateGameMoves(game: game)
    //        shouldEnableButtons(enable: false)
    //    }
    
}
