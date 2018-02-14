//
//  MsgTextNode.swift
//  Msg
//
//  Created by 1amageek on 2018/02/02.
//  Copyright © 2018年 Stamp Inc. All rights reserved.
//

import UIKit
import Pring
import RealmSwift
import AsyncDisplayKit

extension Box {
    open class TextCellNode: ASCellNode {

        public struct Dependency {
            var message: Message
        }

        public let thumbnailImageRadius: CGFloat = 16

        public let thumbnailImageNode: ASNetworkImageNode = ASNetworkImageNode()

        public let nameNode: ASTextNode = ASTextNode()

        public let balloonNode: ASDisplayNode = ASDisplayNode()

        public let textNode: ASTextNode = ASTextNode()

        public init(_ dependency: Dependency) {
            super.init()
            automaticallyManagesSubnodes = true
        }

        open override func didLoad() {
            super.didLoad()
            balloonNode.clipsToBounds = true
            balloonNode.cornerRadius = 16
        }

        open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

            thumbnailImageNode.style.preferredSize = CGSize(width: thumbnailImageRadius * 2, height: thumbnailImageRadius * 2)

            let nameInsetSpec: ASInsetLayoutSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8), child: nameNode)

            let textInsetSpec: ASInsetLayoutSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12), child: textNode)

            let backgroundSpec: ASBackgroundLayoutSpec = ASBackgroundLayoutSpec(child: textInsetSpec, background: balloonNode)

            let verticalStackSpec: ASStackLayoutSpec = ASStackLayoutSpec.vertical()
            verticalStackSpec.children = [nameInsetSpec, backgroundSpec]
            verticalStackSpec.style.flexShrink = 1

            let horizontalStackSpec: ASStackLayoutSpec = ASStackLayoutSpec.horizontal()
            horizontalStackSpec.verticalAlignment = .bottom
            horizontalStackSpec.spacing = 8
            horizontalStackSpec.children = [thumbnailImageNode, verticalStackSpec]

            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 120), child: horizontalStackSpec)
        }
    }

    open class TextLeftCellNode: TextCellNode {

        public override init(_ dependency: Dependency) {
            super.init(dependency)
            if let name: String = dependency.message.sender?.name {
                nameNode.attributedText = NSAttributedString(string: name, attributes: [.font: UIFont.systemFont(ofSize: 14)])
            }

            if let text: String = dependency.message.text {
                textNode.attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 16),
                                                                                        .foregroundColor: UIColor.black])
            }

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
            balloonNode.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1)
        }

        open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

            thumbnailImageNode.style.preferredSize = CGSize(width: thumbnailImageRadius * 2, height: thumbnailImageRadius * 2)

            let nameInsetSpec: ASInsetLayoutSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8), child: nameNode)

            let textInsetSpec: ASInsetLayoutSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12), child: textNode)

            let backgroundSpec: ASBackgroundLayoutSpec = ASBackgroundLayoutSpec(child: textInsetSpec, background: balloonNode)

            let verticalStackSpec: ASStackLayoutSpec = ASStackLayoutSpec.vertical()
            verticalStackSpec.children = [nameInsetSpec, backgroundSpec]
            verticalStackSpec.style.flexShrink = 1

            let horizontalStackSpec: ASStackLayoutSpec = ASStackLayoutSpec.horizontal()
            horizontalStackSpec.verticalAlignment = .bottom
            horizontalStackSpec.spacing = 8
            horizontalStackSpec.children = [thumbnailImageNode, verticalStackSpec]

            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 120), child: horizontalStackSpec)
        }
    }

    open class TextRightCellNode: TextCellNode {

        public override init(_ dependency: Dependency) {
            super.init(dependency)
            if let text: String = dependency.message.text {
                textNode.attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 16),
                                                                                        .foregroundColor: UIColor.white])
            }
        }

        open override func didLoad() {
            super.didLoad()
            balloonNode.backgroundColor = UIColor(red: 23/255.0, green: 135/255.0, blue: 251/255.0, alpha: 1)
        }

        open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

            let textInsetSpec: ASInsetLayoutSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12), child: textNode)

            let backgroundSpec: ASBackgroundLayoutSpec = ASBackgroundLayoutSpec(child: textInsetSpec, background: balloonNode)

            let verticalStackSpec: ASStackLayoutSpec = ASStackLayoutSpec.vertical()
            verticalStackSpec.children = [backgroundSpec]
            verticalStackSpec.style.flexShrink = 1
            verticalStackSpec.horizontalAlignment = .right

            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 2, left: 120, bottom: 2, right: 8), child: verticalStackSpec)
        }
    }
}
