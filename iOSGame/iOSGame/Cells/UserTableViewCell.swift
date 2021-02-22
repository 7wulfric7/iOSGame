//
//  UserTableViewCell.swift
//  iOSGame
//
//  Created by Deniz Adil on 1.2.21.
//

import UIKit
import SnapKit

protocol UserCellDelegate: class {
    func requestGameWith(user: User)
}

class UserTableViewCell: UITableViewCell {
// Storyboard:
//    @IBOutlet weak var lblUserName: UILabel!
//    @IBOutlet weak var btnStart: UIButton!
// SnapKit with code:
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(style: .medium)
        activity.color = .red
        return activity
    }()
    
    private lazy var backgroundImage: UIView = {
        let imageView = UIView()
        imageView.layer.backgroundColor = UIColor.white.cgColor
        imageView.layer.cornerRadius = 20
        return imageView
    }()
    
    private lazy var userImage: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    lazy var lblUsername: UILabel = {
        var label = UILabel()
        label.textColor = UIColor(hex: "4A6495")
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private lazy var btnStart: UIButton = {
        var button = UIButton()
        button.setImage(UIImage(named: "StartGameButton"), for: .normal)
//        button.setTitle("Start Game", for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
//        button.setTitleColor(UIColor(named: "SystemOposite"), for: .normal)
//        button.layer.borderWidth = 1.0
//        button.layer.borderColor = UIColor.red.cgColor
//        button.layer.cornerRadius = 5
//        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(onSart), for: .touchUpInside)
        return button
    }()
    private var user: User?
    weak var delegate: UserCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        selectionStyle = .none
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) //.zero
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(backgroundImage)
        contentView.addSubview(userImage)
        contentView.addSubview(lblUsername)
        contentView.addSubview(btnStart)
        contentView.addSubview(activityIndicator)
        contentView.layer.backgroundColor = UIColor(hex: "F5F8FA").cgColor
        activityIndicator.isHidden = true
        backgroundImage.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().inset(10)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview()
        }
        userImage.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.bottom.equalTo(backgroundImage)
            make.width.equalTo(45)
            make.height.equalTo(50)
        }
        lblUsername.snp.makeConstraints { make in
            make.leading.equalTo(userImage.snp.trailing).offset(20)
            make.top.bottom.equalTo(backgroundImage)
            make.trailing.equalTo(btnStart.snp.leading).inset(10)
        }
        btnStart.snp.makeConstraints { make in
            make.top.bottom.equalTo(backgroundImage).inset(2)
            make.trailing.equalToSuperview().inset(20)
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(btnStart)
        }
    }
    
    @objc private func onSart() {
        guard let user = user else { return }
        delegate?.requestGameWith(user: user)
        btnStart.isHidden = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    func setData(user: User) {
        self.user = user
        lblUsername.text = user.username?.uppercased()
        if let avatar = user.avatarImage {
            userImage.image = UIImage(named: avatar)
        }
        btnStart.isHidden = false
    }
}
