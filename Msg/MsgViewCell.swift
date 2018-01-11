//
//  MsgViewCell.swift
//  Msg
//
//  Created by 1amageek on 2018/01/10.
//  Copyright © 2018年 Stamp Inc. All rights reserved.
//

import UIKit
import ChatView
import Instantiate
import InstantiateStandard

extension MsgViewController {
    public class MsgViewCell: ChatViewCell, Reusable {

        struct Dependency {
            let transcript: Transcript?
        }

        public func inject(_ dependency: MsgViewController<User, Room, Transcript>.MsgViewCell.Dependency) {

            guard let transcript: Transcript = dependency.transcript else {
                return
            }

            if let text: String = transcript.text {
                self.messageView.isHidden = false
                self.messageView.textLabel.text = text
            }

        }

        public private(set) lazy var stackView: UIStackView = {
            let view: UIStackView = UIStackView()
            view.axis = .vertical
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = UIColor.blue
            return view
        }()

        public let imageView: ImageView = ImageView.instantiate()

        public let messageView: MessageView = MessageView.instantiate()

        public override init(frame: CGRect) {
            super.init(frame: frame)
            self.backgroundColor = UIColor.green
            self.translatesAutoresizingMaskIntoConstraints = false

            self.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
            self.heightAnchor.constraint(equalToConstant: 100).isActive = true

//            self.contentView.translatesAutoresizingMaskIntoConstraints = false

//            self.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
//            self.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
//            self.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
//            self.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0).isActive = true
//            self.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0).isActive = true

//            self.contentView.addSubview(stackView)
//            self.contentView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
//            self.contentView.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 0).isActive = true
//            self.contentView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 0).isActive = true
//            self.contentView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 0).isActive = true
//            self.contentView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 0).isActive = true
//
//            imageView.isHidden = true
//            messageView.isHidden = true
//
//            stackView.addArrangedSubview(imageView)
//            stackView.addArrangedSubview(messageView)
        }

        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        public override func prepareForReuse() {
            super.prepareForReuse()
            imageView.isHidden = true
            messageView.isHidden = true
        }
    }

    public class MsgLeftViewCell: MsgViewCell {

        public override init(frame: CGRect) {
            super.init(frame: frame)
            self.contentView.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 0)
            self.contentView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 0)
            self.contentView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 24)
//            stackView.widthAnchor.constraint(equalTo: <#T##NSLayoutDimension#>, multiplier: <#T##CGFloat#>)
        }

        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}



