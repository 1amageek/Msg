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
            return view
        }()

        public let messageView: MessageView = MessageView.instantiate()

        public let imageView: ImageView = ImageView.instantiate()

        public override init(frame: CGRect) {
            super.init(frame: frame)
            self.contentView.addSubview(stackView)
            self.contentView.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 0)
            self.contentView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 0)
            self.contentView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 0)
            self.contentView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 0)

            messageView.isHidden = true
            stackView.addArrangedSubview(messageView)
        }

        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}


