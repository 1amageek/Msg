//
//  MsgViewCell.swift
//  Msg
//
//  Created by 1amageek on 2018/01/10.
//  Copyright © 2018年 Stamp Inc. All rights reserved.
//

import UIKit
import Pring
import Instantiate
import InstantiateStandard
import RealmSwift

extension MsgViewController {
    public class MsgViewCell: UITableViewCell, Reusable {

        struct Dependency {
            let message: Message
        }

        public func inject(_ dependency: MsgViewController<User, Room, Transcript, Message>.MsgViewCell.Dependency) {
            if let text: String = dependency.message.text {
                self.messageView.isHidden = false
                self.messageView.textLabel.text = text
            }
        }

        public private(set) lazy var stackView: UIStackView = {
            let view: UIStackView = UIStackView()
            view.axis = .vertical
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()

        public var contentInset: UIEdgeInsets = UIEdgeInsets(top: 2, left: 32, bottom: 2, right: 24)

        public lazy var widthConstraint: NSLayoutConstraint = {
            return self.contentView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
        }()

        public lazy var heightConstraint: NSLayoutConstraint = {
            return self.contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
        }()

        public lazy var topConstraint: NSLayoutConstraint = {
            return self.stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0)
        }()

        public lazy var bottomConstraint: NSLayoutConstraint = {
            return self.stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)
        }()

        public lazy var leadingConstraint: NSLayoutConstraint = {
            return self.stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: self.contentInset.left)
        }()

        public lazy var trailingConstraint: NSLayoutConstraint = {
            return self.contentView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: self.contentInset.right)
        }()


        public let pictureView: ImageView = ImageView.instantiate()

        public let messageView: MessageView = MessageView.instantiate()

        public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            self.contentView.translatesAutoresizingMaskIntoConstraints = false
            self.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
            self.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
            self.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
            self.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true

            self.contentView.addSubview(stackView)
            self.widthConstraint.isActive = true
            self.heightConstraint.isActive = true
            self.topConstraint.isActive = true
            self.bottomConstraint.isActive = true
            self.leadingConstraint.isActive = true
            self.trailingConstraint.isActive = true

            self.stackView.addArrangedSubview(messageView)
        }

        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        public override func prepareForReuse() {
            super.prepareForReuse()
            pictureView.isHidden = true
            messageView.isHidden = true
        }
    }

    public class MsgLeftViewCell: MsgViewCell {

        public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            self.leadingConstraint.isActive = true
            self.trailingConstraint.isActive = false
            self.stackView.widthAnchor.constraint(lessThanOrEqualTo: self.contentView.widthAnchor, multiplier: 0.8).isActive = true
        }

        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    public class MsgRightViewCell: MsgViewCell {

        public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            self.leadingConstraint.isActive = false
            self.trailingConstraint.isActive = true
            self.stackView.widthAnchor.constraint(lessThanOrEqualTo: self.contentView.widthAnchor, multiplier: 0.8).isActive = true
//            self.stackView.widthAnchor.constraint(lessThanOrEqualTo: self.contentView.widthAnchor, multiplier: 0.8).isActive = true
        }

        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}



