//
//  MsgViewController.swift
//  Msg
//
//  Created by 1amageek on 2018/01/10.
//  Copyright © 2018年 Stamp Inc. All rights reserved.
//

import UIKit
import Pring
import Toolbar
import Instantiate
import InstantiateStandard
import OnTheKeyboard
import MsgBox
import RealmSwift

class MsgViewController<User: UserDocument, Room: RoomDocument, Transcript, Message: MessageProtocol>: UIViewController, UITableViewDelegate, UITableViewDataSource, OnTheKeyboard, UITextViewDelegate where Message: RealmSwift.Object, Message.Transcript == Transcript {

    let roomID: String

    let userID: String

    let sessionController: MsgBox<User, Room, Transcript, Message>.SessionController

    init(roomID: String, userID: String) {
        self.roomID = roomID
        self.userID = userID
        self.sessionController = MsgBox.SessionController(roomID: roomID)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var keyboardObservers: [Any] = []

    var toolBar: Toolbar = Toolbar()

    var toolbarBottomConstraint: NSLayoutConstraint?

    private(set) lazy var tableView: UITableView = {
        let view: UITableView = UITableView(frame: self.view.bounds, style: .plain)
        view.delegate = self
        view.dataSource = self
        view.register(type: MsgViewCell.self)
        view.register(type: MsgLeftViewCell.self)
        view.register(type: MsgRightViewCell.self)
        view.keyboardDismissMode = .interactive
        return view
    }()

    private func _layoutTableView(_ frame: CGRect = .zero, isHidden: Bool) {
        let keyboardHeight: CGFloat = isHidden ? 0 : frame.height
        let toolbarHeight: CGFloat = isHidden ? self.toolBar.bounds.height : (self.toolBar.bounds.height - self.view.safeAreaInsets.bottom)
        let height: CGFloat = toolbarHeight + keyboardHeight - self.view.safeAreaInsets.bottom
        self.tableView.contentInset.bottom = height
        self.tableView.scrollIndicatorInsets.bottom = height
    }

    override func loadView() {
        super.loadView()
        self.view.addSubview(tableView)
        showToolBar(view)
        self.toolBar.setItems([ToolbarItem(customView: self.textView), self.sendBarItem], animated: false)
        self.toolBar.layoutIfNeeded()
        _layoutTableView(isHidden: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addKeyboardObservers()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeKeyboardObservers()
    }

    func keyboardWillLayout(_ frame: CGRect, isHidden: Bool) {
        _layoutTableView(frame, isHidden: isHidden)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.sessionController.listen()
    }

    // MARK: -

    var constraint: NSLayoutConstraint?

    private(set) lazy var sendBarItem: ToolbarItem = {
        let item: ToolbarItem = ToolbarItem(title: "Send", target: self, action: #selector(_send))
        return item
    }()

    private(set) lazy var textView: UITextView = {
        let textView: UITextView = UITextView(frame: .zero)
        textView.delegate = self
        textView.font = UIFont.systemFont(ofSize: 16)
        return textView
    }()

    @objc private func _send() {
        let text: String = self.textView.text
        guard !text.isEmpty else {
            return
        }

        self.sendBarItem.isEnabled = true
        self.textView.text = ""
        var transcript: Transcript = Transcript()
        let room: Room = Room(id: self.roomID)
        transcript.text = text
        transcript.room.set(room as! Transcript.Room)
        transcript.user.set((User(id: self.userID) as! Transcript.User))
        if let constraint: NSLayoutConstraint = self.constraint {
            textView.removeConstraint(constraint)
        }
        self.toolBar.setNeedsLayout()
        room.transcripts.insert(transcript as! Room.Transcript, block: { error in
            print(error)
        })
    }

    // MARK:

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message: Message = self.dataSource[indexPath.item]
        if message.userID == self.userID {
            return MsgRightViewCell.dequeue(from: tableView, for: indexPath, with: .init(message: message))
        }
        return MsgLeftViewCell.dequeue(from: tableView, for: indexPath, with: .init(message: message))
    }

    // MARK: - Realm

    let realm = try! Realm()

    private(set) var notificationToken: NotificationToken?

    private(set) lazy var dataSource: Results<Message> = {
        var results: Results<Message> = self.realm.objects(Message.self)
            .filter("roomID == %@", self.roomID)
            .sorted(byKeyPath: "updatedAt")
        self.notificationToken = results.observe { [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial: tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                tableView.performBatchUpdates({
                    tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                    tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}), with: .automatic)
                    tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                }, completion: nil)
            case .error(let error): fatalError("\(error)")
            }
        }
        return results
    }()

    deinit {
        self.notificationToken?.invalidate()
    }

    // MARK:

    func textViewDidChange(_ textView: UITextView) {
        let size: CGSize = textView.sizeThatFits(textView.bounds.size)
        if let constraint: NSLayoutConstraint = self.constraint {
            textView.removeConstraint(constraint)
        }
        self.constraint = textView.heightAnchor.constraint(equalToConstant: size.height)
        self.constraint?.priority = .defaultHigh
        self.constraint?.isActive = true
    }
}
