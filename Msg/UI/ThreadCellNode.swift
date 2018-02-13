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
    class ThreadCellNode: ASCellNode {

        public struct Dependency {
            var thread: Thread
        }

        let thumbnailImageRadius: CGFloat = 16

        let thumbnailImageNode: ASNetworkImageNode = ASNetworkImageNode()

        let nameNode: ASTextNode = ASTextNode()

        let balloonNode: ASDisplayNode = ASDisplayNode()

        let textNode: ASTextNode = ASTextNode()

        let aaaNode: ASTextNode = ASTextNode()

        init(_ dependency: Dependency) {
            super.init()
            automaticallyManagesSubnodes = true
            nameNode.attributedText = NSAttributedString(string: "hannahmbanana")
            textNode.attributedText = NSAttributedString(string: "dependency.text")
            aaaNode.attributedText = NSAttributedString(string: "hawwwwwwwwefwefnnahmbanana")
            thumbnailImageNode.willDisplayNodeContentWithRenderingContext = { context, drawParameters in
                let bounds = context.boundingBoxOfClipPath
                UIBezierPath(roundedRect: bounds, cornerRadius: self.thumbnailImageRadius).addClip()
            }
        }

        override func didLoad() {
            super.didLoad()
            thumbnailImageNode.backgroundColor = UIColor.lightGray
            balloonNode.backgroundColor = UIColor(red: 23/255.0, green: 135/255.0, blue: 251/255.0, alpha: 1)
        }

        override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

            thumbnailImageNode.style.preferredSize = CGSize(width: thumbnailImageRadius * 2, height: thumbnailImageRadius * 2)

            let nameInsetSpec: ASInsetLayoutSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8), child: nameNode)

            let textInsetSpec: ASInsetLayoutSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12), child: textNode)

            let backgroundSpec: ASBackgroundLayoutSpec = ASBackgroundLayoutSpec(child: textInsetSpec, background: balloonNode)

            let verticalStackSpec: ASStackLayoutSpec = ASStackLayoutSpec.vertical()
            verticalStackSpec.children = [nameInsetSpec, backgroundSpec]
            verticalStackSpec.style.flexShrink = 1

            let horizontalStackSpec: ASStackLayoutSpec = ASStackLayoutSpec.horizontal()
            horizontalStackSpec.verticalAlignment = .bottom
            horizontalStackSpec.spacing = 8
            horizontalStackSpec.children = [thumbnailImageNode, verticalStackSpec]

            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 120), child: horizontalStackSpec)
        }
    }
}
