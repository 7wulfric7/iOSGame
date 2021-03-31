//
//  HomeViewController.swift
//  iOSGame
//
//  Created by Deniz Adil on 1.2.21.
//

import UIKit
import SwiftMessages

class HomeViewController: UIViewController, AlertPresenter {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHolderView: UIView!
    @IBOutlet weak var btnExpand: UIButton!
    @IBOutlet weak var tableHolderBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarHolderView: UIView!
    
    var loadingView: LoadingView?
    var users = [User]()
    var game: Game?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if targetEnvironment(simulator)
        DataStore.shared.setGameRequestListener()
        #else
        requestPushNotifications()
        #endif
        
        title = "Welcome " + (DataStore.shared.localUser?.username ?? "")
//        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveGameRequest(_:)), name: Notification.Name("DidReceiveGameRequestNotification"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveGameRequest(_:)), name: Notification.Name("AcceptGameRequestNotification"), object: nil)
        NotificationCenter.default.addObserver(forName: Notification.Name("AcceptGameRequestNotification"), object: nil, queue: nil) { [weak self] notification in
            guard let userInfo = notification.userInfo as? [String:Any], let gameRequest = userInfo["GameRequest"] as? GameRequest else {return}
            self?.acceptRequest(gameRequest)
        }
        setupTable()
        setupAvatarView()
        getUsers()
        //        DataStore.shared.setUsersListener {
        //            self.getUsers()
        //        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DataStore.shared.setUsersListener { [weak self] in
            self?.getUsers()
        }
        if let _ = PushNotificationsManager.shared.getGameRequest() {
//            showGameRequestAlert(gameRequest: request)
            PushNotificationsManager.shared.clearVariables()
//            DataStore.shared.setAcceptGameRequestListener(request)
        }
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.checkForEnableedPushNotifications(completion: { (enabled) in
            if !enabled {
                DataStore.shared.setGameRequestListener()
            }
        })
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DataStore.shared.removeUsersListener()
        DataStore.shared.removeGameRequestListener()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    private func requestPushNotifications() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.requestNotificationsPermission()
    }
    
    private func setupAvatarView() {
        let avatarView = AvatarView(state: .imageAndName)
        avatarHolderView.addSubview(avatarView)
        avatarView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(5)
        }
        avatarView.username = DataStore.shared.localUser?.username
        avatarView.image = DataStore.shared.localUser?.avatarImage
    }
    
    private func setupTable() {
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.reuseIdentifier)
    }
    
//    private func showGameRequestAlert(gameRequest: GameRequest) {
//        let fromUsername = gameRequest.fromUsername ?? ""
//        let alert = UIAlertController(title: "Game Request", message: "\(fromUsername) invited you for a game", preferredStyle: .alert)
//        let accept = UIAlertAction(title: "Accept", style: .default) { _ in
//            self.acceptRequest(gameRequest)
//        }
//        let decline = UIAlertAction(title: "Decline", style: .cancel) { _ in
//            self.declineRequest(gameRequest: gameRequest)
//        }
//        alert.addAction(accept)
//        alert.addAction(decline)
//        present(alert, animated: true, completion: nil)
//    }
    
//    @objc private func didReceiveGameRequest(_ notification: Notification) {
//        guard let userInfo = notification.userInfo as? [String: GameRequest] else { return }
//        guard let gameRequest = userInfo["GameRequest"] else { return }
////        showGameRequestAlert(gameRequest: gameRequest)
//        acceptRequest(gameRequest)
//    }
    
//    @objc private func acceptGameRequest(_ notification: Notification) {
//        didReceiveGameRequest(notification)
//    }
    
    private func getUsers() {
        DataStore.shared.getAllUsers { [weak self] (users, error) in
            guard let self = self else { return }
            if let users = users {
                self.users = users.filter({$0.id != DataStore.shared.localUser?.id})
                self.tableView.reloadData()
            }
        }
    }
    
    private func declineRequest(gameRequest: GameRequest) {
        DataStore.shared.deleteGameRequest(gameRequest: gameRequest)
    }
    
    private func acceptRequest(_ gameRequest: GameRequest) {
        guard let localUser = DataStore.shared.localUser else { return }
        DataStore.shared.getUserWith(id: gameRequest.from) { [weak self] (user, error) in
            if let error = error {
                //TODO: Hanlde user not found property
                print(error.localizedDescription)
                return
            }
            if let user = user {
                DataStore.shared.createGame(players:[localUser, user]) { (game, error) in
                    DataStore.shared.deleteGameRequest(gameRequest: gameRequest)
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    if let game = game {
                        self?.enterGame(game)
                        SwiftMessages.hide()
                    }
                    
                }
            }
        }
    }
    
    private func enterGame(_ game: Game,_ shouldUpdateGame: Bool = false) {
        DataStore.shared.removeGameListener()
        if shouldUpdateGame {
            var newGame = game
            newGame.state = .inprogress
            var newState = game
            newState.state = .finished
            DataStore.shared.updateGameStatus(game: newGame, newState: Game.GameState.inprogress.rawValue)
            performSegue(withIdentifier: "gameSeque", sender: newGame)
        } else {
            performSegue(withIdentifier: "gameSeque", sender: game)
        }
    }
    
    
    @IBAction func onExpand(_ sender: UIButton) {
        let isExpanded = tableHolderBottomConstraint.constant == 0
        tableHolderBottomConstraint.constant = isExpanded ? tableHolderView.frame.height : 0
        self.btnExpand.setImage(UIImage(named: isExpanded ? "ButtonDown" : "ButtonUp"), for: .normal)
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseInOut]) {
            self.view.layoutIfNeeded()
            // Animating frames instead of constraints:
            //            self.tableHolderView.frame.origin = CGPoint(x: self.tableHolderView.frame.origin.x, y: -self.tableHolderView.frame.size.height)
        } completion: { completed in
            if completed {
                // animation is completed
                
            }
        }
    }

}

//MARK: = Navigation
extension HomeViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "gameSeque" else { return }
        let gameController = segue.destination as! GameViewController
        gameController.game = sender as? Game
    }
}
// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.reuseIdentifier) as! UserTableViewCell
        let user = users[indexPath.row]
        cell.setData(user: user)
        cell.delegate = self
        return cell
    }
}

// MARK: - UserCellDelegate
extension HomeViewController: UserCellDelegate {
    func requestGameWith(user: User) {
        guard let userId = user.id,
              let localUser = DataStore.shared.localUser,
              let localUserId = localUser.id else {return}
        DataStore.shared.checkForExtistingGameRequest(toUser: userId, fromUser: localUserId) { [weak self] (exists, error) in
            if let error = error {
                print(error.localizedDescription)
                print("Error checking for game, try again later")
                return
            }
            if !exists {
                self?.checkForOngoingGame(userId: userId, localUser: localUser, opponent: user)
            }
        }
    }
    
    func checkForOngoingGame(userId: String, localUser: User, opponent: User) {
        guard let opponentUsername = opponent.username else { return }
        let alert = UIAlertController(title: "\(opponentUsername) already in game", message: "Please choose another opponent", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(confirm)
        DataStore.shared.checkForOngoingGameWith(userId: userId) { [weak self] (userInGame, error) in
            if !userInGame {
                self?.setGameRequestTo(userId: userId, localUser: localUser, opponent: opponent)
            } else {
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func setGameRequestTo(userId: String, localUser: User, opponent: User) {
        DataStore.shared.startGameRequest(userID: userId) { [weak self] (request, error) in
            if request != nil {
                
                self?.setupLoadingView(me: localUser, opponent: opponent, request: request)
            }
        }
    }
}


// MARK: - LoadingViewHandling
extension HomeViewController {
    func setupLoadingView(me: User, opponent: User, request: GameRequest?) {
        if loadingView != nil {
            loadingView?.removeFromSuperview()
            loadingView = nil
        }
        loadingView = LoadingView(me: me, opponent: opponent, request: request, alertPresenter: self)
        loadingView?.gameAccepted = { [weak self] game in
            self?.enterGame(game, true)
        }
        view.addSubview(loadingView!)
        loadingView?.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        tableView.reloadData()
    }
    
    func hideLoadingView() {
        loadingView?.removeFromSuperview()
        loadingView = nil
    }
}

