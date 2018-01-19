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

        public private(set) lazy var balloonView: UIView = {
            let view: UIView = UIView(frame: .zero)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.clipsToBounds = true
            view.layer.cornerRadius = self.bolloonCornerRadius
            view.backgroundColor = .clear
            return view
        }()

        public var contentInset: UIEdgeInsets = UIEdgeInsets(top: 1, left: 48, bottom: 1, right: 24)

        public var bolloonWidth: CGFloat = 0.65

        public var bolloonCornerRadius: CGFloat = 16

        public lazy var widthConstraint: NSLayoutConstraint = {
            return self.contentView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
        }()

        public lazy var heightConstraint: NSLayoutConstraint = {
            return self.contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
        }()

        public lazy var balloonTopConstraint: NSLayoutConstraint = {
            return self.stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: self.contentInset.top)
        }()

        public lazy var balloonBottomConstraint: NSLayoutConstraint = {
            return self.contentView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: self.contentInset.bottom)
        }()

        public lazy var balloonLeadingConstraint: NSLayoutConstraint = {
            return self.stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: self.contentInset.left)
        }()

        public lazy var balloonTrailingConstraint: NSLayoutConstraint = {
            return self.contentView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: self.contentInset.right)
        }()

        public lazy var balloonWidthConstraint: NSLayoutConstraint = {
            return self.stackView.widthAnchor.constraint(lessThanOrEqualTo: self.contentView.widthAnchor, multiplier: self.bolloonWidth)
        }()


        public let pictureView: ImageView = ImageView.instantiate()

        public let messageView: MessageView = MessageView.instantiate()

        public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            self.separatorInset.left = UIScreen.main.bounds.width
            self.contentView.translatesAutoresizingMaskIntoConstraints = false
            self.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
            self.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
            self.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
            self.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
            self.contentView.addSubview(stackView)
            self.stackView.addSubview(balloonView)
            self.balloonView.topAnchor.constraint(equalTo: self.stackView.topAnchor).isActive = true
            self.balloonView.bottomAnchor.constraint(equalTo: self.stackView.bottomAnchor).isActive = true
            self.balloonView.leadingAnchor.constraint(equalTo: self.stackView.leadingAnchor).isActive = true
            self.balloonView.trailingAnchor.constraint(equalTo: self.stackView.trailingAnchor).isActive = true
            self.widthConstraint.isActive = true
            self.heightConstraint.isActive = true
            self.balloonTopConstraint.isActive = true
            self.balloonBottomConstraint.isActive = true
            self.balloonLeadingConstraint.isActive = true
            self.balloonTrailingConstraint.isActive = true

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

        public override func setHighlighted(_ highlighted: Bool, animated: Bool) {

        }

        public override func setSelected(_ selected: Bool, animated: Bool) {
            
        }
    }

    public class MsgLeftViewCell: MsgViewCell {

        let thumbnailRadius: CGFloat = 16

        public private(set) lazy var thumbnailImageView: UIImageView = {
            let view: UIImageView = UIImageView(frame: .zero)
            view.clipsToBounds = true
            view.contentMode = .scaleAspectFit
            view.layer.cornerRadius = self.thumbnailRadius
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = UIColor.lightGray
            return view
        }()

        public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            self.balloonLeadingConstraint.isActive = true
            self.balloonTrailingConstraint.isActive = false
            self.balloonWidthConstraint.isActive = true
            self.messageView.textLabel.textColor = UIColor.darkText
            self.balloonView.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1)
            self.contentView.addSubview(thumbnailImageView)
            thumbnailImageView.widthAnchor.constraint(equalToConstant: self.thumbnailRadius * 2).isActive = true
            thumbnailImageView.heightAnchor.constraint(equalToConstant: self.thumbnailRadius * 2).isActive = true
            contentView.bottomAnchor.constraint(equalTo: self.thumbnailImageView.bottomAnchor, constant: self.contentInset.bottom).isActive = true
            thumbnailImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 8).isActive = true
        }

        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    public class MsgRightViewCell: MsgViewCell {

        public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            self.balloonLeadingConstraint.isActive = false
            self.balloonTrailingConstraint.isActive = true
            self.balloonWidthConstraint.isActive = true
            self.messageView.textLabel.textColor = UIColor.white
            self.balloonView.backgroundColor = UIColor(red: 23/255.0, green: 135/255.0, blue: 251/255.0, alpha: 1)
        }

        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}



