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
    lazy var lblUsername: UILabel = {
       var label = UILabel()
        label.textColor = UIColor(named: "SystemOposite")
        return label
    }()
    private lazy var btnStart: UIButton = {
        var button = UIButton()
        button.setTitle("Start Game", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setTitleColor(UIColor(named: "SystemOposite"), for: .normal)
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.red.cgColor
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
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
        contentView.addSubview(lblUsername)
        contentView.addSubview(btnStart)
        contentView.addSubview(activityIndicator)
        activityIndicator.isHidden = true
        lblUsername.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.bottom.equalToSuperview()
            make.trailing.equalTo(btnStart.snp.leading).inset(10)
        }
        btnStart.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(2)
            make.trailing.equalToSuperview().inset(20)
            make.width.equalTo(70)
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
        lblUsername.text = user.username
        btnStart.isHidden = false
    }
}
