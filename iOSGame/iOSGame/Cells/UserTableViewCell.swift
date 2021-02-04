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
     
    lazy var lblUsername: UILabel = {
       var label = UILabel()
        label.textColor = .black
        label.backgroundColor = .white
        return label
    }()
    private lazy var btnStart: UIButton = {
        var button = UIButton()
        button.setTitle("Start Game", for: .normal)
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(lblUsername)
        contentView.addSubview(btnStart)
        
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
    }
    
    @objc private func onSart() {
        guard let user = user else { return }
        delegate?.requestGameWith(user: user)
    }
    func setData(user: User) {
        self.user = user
        lblUsername.text = user.username
    }
}
