//
//  ThreadCellNode.swift
//  Msg
//
//  Created by 1amageek on 2018/02/02.
//  Copyright © 2018年 Stamp Inc. All rights reserved.
//

import UIKit
import AsyncDisplayKit

extension Box {
    open class ThreadCellNode: ASCellNode {

        public struct Dependency {
            var userID: String
            var thread: Thread
        }

        public let thumbnailImageRadius: CGFloat = 24

        public let badgeRadius: CGFloat = 12

        public let thumbnailImageNode: ASNetworkImageNode = ASNetworkImageNode()

        public let nameNode: ASTextNode = ASTextNode()

        public let textNode: ASTextNode = ASTextNode()

        public let dateNode: ASTextNode = ASTextNode()

        public let badgeNode: ASDisplayNode = ASDisplayNode()

        public let badgeCountNode: ASTextNode = ASTextNode()

        public let dateFormatter: DateFormatter = {
            let formatter: DateFormatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            formatter.doesRelativeDateFormatting = true
            return formatter
        }()

        public init(_ dependency: Dependency) {
            super.init()
            automaticallyManagesSubnodes = true
            if let name: String = dependency.thread.name {
                nameNode.attributedText = NSAttributedString(string: name,
                                                             attributes: [.foregroundColor: UIColor.darkText,
                                                                          .font: UIFont.boldSystemFont(ofSize: 16)])
            }
            if let text: String = dependency.thread.lastMessage?.text {
                textNode.attributedText = NSAttributedString(string: text,
                                                             attributes: [.foregroundColor: UIColor.darkText,
                                                                          .font: UIFont.boldSystemFont(ofSize: 16)])
            }
            if let date: Date = dependency.thread.lastMessage?.updatedAt {
                dateNode.attributedText = NSAttributedString(string: self.dateFormatter.string(from: date))
            }

            badgeCountNode.attributedText = NSAttributedString(string: "00", attributes: [.foregroundColor: UIColor.white,
                                                                                          .font: UIFont.boldSystemFont(ofSize: 15)])

            thumbnailImageNode.willDisplayNodeContentWithRenderingContext = { context, drawParameters in
                let bounds = context.boundingBoxOfClipPath
                UIBezierPath(roundedRect: bounds, cornerRadius: self.thumbnailImageRadius).addClip()
            }
        }

        open override func didLoad() {
            super.didLoad()
            thumbnailImageNode.backgroundColor = UIColor.lightGray
            thumbnailImageNode.clipsToBounds = true
            thumbnailImageNode.cornerRadius = thumbnailImageRadius

            badgeNode.backgroundColor = UIColor.red
            badgeNode.clipsToBounds = true
            badgeNode.cornerRadius = badgeRadius
        }

        open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

            thumbnailImageNode.style.preferredSize = CGSize(width: thumbnailImageRadius * 2, height: thumbnailImageRadius * 2)

            let nameInsetSpec: ASInsetLayoutSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: nameNode)
            let textInsetSpec: ASInsetLayoutSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: textNode)
            let centerStackSpec: ASStackLayoutSpec = ASStackLayoutSpec.vertical()
            centerStackSpec.children = [nameInsetSpec, textInsetSpec]
            centerStackSpec.style.flexShrink = 1
            centerStackSpec.style.flexGrow = 1

            let dateInsetSpec: ASInsetLayoutSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8), child: dateNode)
            let badgeCountInsetSpec: ASInsetLayoutSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8), child: badgeCountNode)
            let backgroundSpec: ASBackgroundLayoutSpec = ASBackgroundLayoutSpec(child: badgeCountInsetSpec, background: badgeNode)
            let badgeCountSpec: ASCenterLayoutSpec = ASCenterLayoutSpec(horizontalPosition: .center, verticalPosition: .center, sizingOption: .minimumSize, child: backgroundSpec)

            let rightStackSpec: ASStackLayoutSpec = ASStackLayoutSpec.vertical()
            rightStackSpec.children = [dateInsetSpec, badgeCountSpec]
            rightStackSpec.style.flexShrink = 1

            let horizontalStackSpec: ASStackLayoutSpec = ASStackLayoutSpec.horizontal()
            horizontalStackSpec.verticalAlignment = .top
            horizontalStackSpec.spacing = 16
            horizontalStackSpec.children = [thumbnailImageNode, centerStackSpec, rightStackSpec]

            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16), child: horizontalStackSpec)
        }
    }
}
