//
//  ThreadViewController.swift
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
    open class ThreadViewController: ASViewController<ASTableNode>, ASTableDelegate, ASTableDataSource {

        public let userID: String

        public let sessionController: Box<Thread, Sender, Message, Viewer>.RoomController

        public init(userID: String) {
            self.userID = userID
            self.sessionController = Box.RoomController(userID: userID)
            super.init(node: tableNode)
        }

        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        public lazy var tableNode: ASTableNode = {
            let node: ASTableNode = ASTableNode(style: .plain)
            node.delegate = self
            node.dataSource = self
            return node
        }()

        public var tableView: UITableView {
            return self.tableNode.view
        }

        open override func loadView() {
            super.loadView()
//            tableNode.view.separatorStyle = .none
        }

        open override func viewDidLoad() {
            super.viewDidLoad()
            self.sessionController.listen()
        }

        open func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
            return self.dataSource.count
        }

        open func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
            let thread: Thread = self.dataSource[indexPath.item]
            let viewController: MessageViewController = MessageViewController(roomID: thread.id, userID: self.userID)
            self.navigationController?.pushViewController(viewController, animated: true)
        }

        open func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
            let thread: Thread = self.dataSource[indexPath.item]
            let ref = ThreadSafeReference(to: thread)
            return {
                let realm = try! Realm()
                guard let thread = realm.resolve(ref) else {
                    fatalError()
                }
                let dependency: ThreadCellNode.Dependency = ThreadCellNode.Dependency(thread: thread)
                return ThreadCellNode(dependency)
            }
        }

        // MARK: - Realm

        let realm = try! Realm()

        private(set) var notificationToken: NotificationToken?

        private(set) lazy var dataSource: Results<Thread> = {
            var results: Results<Thread> = self.realm.objects(Thread.self)
                .sorted(byKeyPath: "updatedAt")
            self.notificationToken = results.observe { [weak self] (changes: RealmCollectionChange) in
                guard let tableNode = self?.tableNode else { return }
                switch changes {
                case .initial:
                    tableNode.reloadData()
                case .update(_, let deletions, let insertions, let modifications):
                    tableNode.performBatchUpdates({
                        tableNode.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                        tableNode.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}), with: .automatic)
                        tableNode.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                    }) { finished in

                    }
                case .error(let error): fatalError("\(error)")
                }
            }
            return results
        }()

        deinit {
            self.notificationToken?.invalidate()
        }
    }
}


