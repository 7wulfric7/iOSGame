//
//  LoadingView.swift
//  iOSGame
//
//  Created by Deniz Adil on 10.2.21.
//

import UIKit
import SnapKit

class LoadingView: UIView {
    
    private lazy var avatarMe: AvatarView = {
        let avatar = AvatarView(state: .lodaing)
        return avatar
    }()

    private lazy var avatarOpponent: AvatarView = {
        let avatar = AvatarView(state: .lodaing)
        return avatar
    }()
    
    private lazy var lblVs: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 56, weight: .heavy)
        label.textColor = UIColor(hex: "#FFB24C")
        label.text = "VS"
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private lazy var lblRequestStatus: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = UIColor(hex: "#FFB24C")
        return label
    }()
    
    private lazy var gradientView: UIImageView = {
       let imageView = UIImageView(image: UIImage(named: "gradientBackground"))
        return imageView
    }()
    
    private var btnClose: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .medium)
        button.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        button.addTarget(self, action: #selector(onClose), for: .touchUpInside)
        button.tintColor = .black
        button.isHidden = true
        return button
    }()
    
    private var me: User
    private var opponent: User
    private var closeTimer: Timer?
    private var cancelGameTimer: Timer?
    private var gameRequest: GameRequest?
    private var elapsedSeconds = 0
    private var alertPresenter: AlertPresenter?
    var gameAccepted: ((_ game: Game) -> Void)?
    
    init(me: User, opponent: User, request: GameRequest?, alertPresenter: AlertPresenter? = nil) {
        self.me = me
        self.opponent = opponent
        gameRequest = request
        self.alertPresenter = alertPresenter
        super.init(frame: .zero)
        backgroundColor = UIColor(hex: "#3545C8")
        setupViews()
        setupData()
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        // When superview is not 'nil' then it's "addSubView" method
        if newSuperview != nil {
            setupTimers()
            setGameListener()
        }
        //When superView is 'nil' then is "removeFromSuperView" method
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func removeTimers() {
        closeTimer?.invalidate()
        closeTimer = nil
        cancelGameTimer?.invalidate()
        cancelGameTimer = nil
    }
    
    private func setGameRequestDelitionListener() {
        DataStore.shared.setGameRequestDeletionListener { [weak self] in
            self?.removeTimers()
            self?.removeFromSuperview()
            self?.alertPresenter?.showGameRequestDeclineedAlert()
        }
    }
    
    private func setGameListener() {
        DataStore.shared.setGameListener { [weak self] (game, _) in
            guard let game = game else { return }
            self?.gameAccepted?(game)
            self?.removeTimers()
            self?.removeFromSuperview()
        }
    }
    
    private func setupTimers() {
        closeTimer = Timer.scheduledTimer(timeInterval: CancelGameSeconds, target: self, selector: #selector(enableCancelGame), userInfo: nil, repeats: false)
        cancelGameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerTick), userInfo: nil, repeats: true)
    }
    
    @objc func enableCancelGame() {
        btnClose.isHidden = false
        closeTimer?.invalidate()
        closeTimer = nil
    }
    
    @objc func timerTick() {
        elapsedSeconds += 1 //elapsedSeconds = elapsedSeconds + 1
        if elapsedSeconds == WaitingGameSeconds {
            cancelGameTimer?.invalidate()
            cancelGameTimer = nil
            onClose()
        }
    }
    
    private func setupViews() {
        addSubview(gradientView)
        addSubview(avatarMe)
        addSubview(lblVs)
        addSubview(avatarOpponent)
        addSubview(lblRequestStatus)
        addSubview(btnClose)
        btnClose.snp.makeConstraints { (make) in
            make.leading.top.equalToSuperview().inset(50)
            make.size.equalTo(50)
        }
        gradientView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        avatarMe.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.width.equalTo(130)
            make.height.equalTo(200)
            make.centerX.equalToSuperview()
        }
        lblVs.snp.makeConstraints { make in
            make.size.equalTo(80)
            make.top.equalTo(avatarMe.snp.bottom).offset(25)
            make.centerX.equalToSuperview()
        }
        avatarOpponent.snp.makeConstraints { (make) in
            make.width.equalTo(130)
            make.height.equalTo(200)
            make.centerX.equalToSuperview()
            make.top.equalTo(lblVs.snp.bottom).offset(25)
        }
        lblRequestStatus.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(30)
        }
    }
    
    private func setupData() {
        avatarMe.username = me.username
        avatarOpponent.username = opponent.username
        avatarMe.image = me.avatarImage ?? "avatarOne"
        avatarOpponent.image = opponent.avatarImage ?? "avatarThree"
        lblRequestStatus.text = "Waiting opponent..."
    }
    
    @objc private func onClose() {
        guard let request = gameRequest else {return}
        cancelGameTimer?.invalidate()
        cancelGameTimer = nil
        DataStore.shared.deleteGameRequest(gameRequest: request)
        removeFromSuperview()
    }
}
