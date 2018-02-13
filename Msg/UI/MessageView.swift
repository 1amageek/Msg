//
//  MsgView.swift
//  Msg
//
//  Created by 1amageek on 2018/02/05.
//  Copyright © 2018年 Stamp Inc. All rights reserved.
//

import UIKit
import AsyncDisplayKit

public class MsgView: ASDisplayNode {

    public let tableNode: ASTableNode = ASTableNode(style: .plain)

    public var tableView: ASTableView {
        return self.tableNode.view
    }

    public override init() {
        super.init()
        automaticallyManagesSubnodes = true
    }

    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: tableNode)
    }
}
