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

extension MsgViewController {
    public class MsgViewCell: UITableViewCell, Reusable {

        struct Dependency {
            let transcript: Transcript?
        }

        public private(set) lazy var stackView: UIStackView = {
            let view: UIStackView = UIStackView()
            view.axis = .vertical
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()

        public lazy var widthConstraint: NSLayoutConstraint = {
            return self.contentView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
        }()

        public lazy var heightConstraint: NSLayoutConstraint = {
            return self.contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
        }()

        public lazy var topConstraint: NSLayoutConstraint = {
            return self.contentView.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 0)
        }()

        public lazy var bottomConstraint: NSLayoutConstraint = {
            return self.contentView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 0)
        }()

        public lazy var leadingConstraint: NSLayoutConstraint = {
            return self.contentView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 0)
        }()

        public lazy var trailingConstraint: NSLayoutConstraint = {
            return self.contentView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 0)
        }()

        public func inject(_ dependency: MsgViewController<User, Room, Transcript>.MsgViewCell.Dependency) {
            guard let transcript: Transcript = dependency.transcript else {
                return
            }

            //            if let image: File = transcript.image {
            //
            //            }

            if let text: String = transcript.text {
                self.messageView.isHidden = false
                self.messageView.textLabel.text = text
            }
        }

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
            self.leadingConstraint.constant = -24
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
            self.trailingConstraint.constant = 32
            self.leadingConstraint.isActive = false
            self.stackView.widthAnchor.constraint(lessThanOrEqualTo: self.contentView.widthAnchor, multiplier: 0.8).isActive = true
//            self.stackView.widthAnchor.constraint(lessThanOrEqualTo: self.contentView.widthAnchor, multiplier: 0.8).isActive = true
        }

        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}



