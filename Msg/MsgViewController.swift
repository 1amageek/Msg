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
import Typist

class MsgViewController<User: UserDocument, Room: RoomDocument, Transcript: TranscriptDocument>: UIViewController, UITableViewDelegate, UITableViewDataSource, OnTheKeyboard, UITextViewDelegate {

    var room: Room

    var user: User

    var dataSource: DataSource<Transcript>?

    init(room: Room, user: User) {
        self.room = room
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var keyboardObservers: [Any] = []

    var toolBar: Toolbar = Toolbar()

    var toolbarBottomConstraint: NSLayoutConstraint?

    let keyboard = Typist.shared

    private(set) lazy var tableView: UITableView = {
        let view: UITableView = UITableView(frame: self.view.bounds, style: .plain)
        view.delegate = self
        view.dataSource = self
        view.register(type: MsgViewCell.self)
        view.register(type: MsgLeftViewCell.self)
        view.register(type: MsgRightViewCell.self)
        view.keyboardDismissMode = .interactive
        view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Toolbar.defaultHeight, right: 0)
        return view
    }()

    private func _layoutTableView() {
        var contentInset: UIEdgeInsets = tableView.contentInset
        contentInset.bottom = self.toolbarBottomConstraint?.constant ?? Toolbar.defaultHeight
        tableView.contentInset = contentInset
    }

    override func loadView() {
        super.loadView()
        self.view.addSubview(tableView)
        showToolBar(view)
        self.toolBar.setItems([ToolbarItem(customView: self.textView), self.sendBarItem], animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addKeyboardObservers()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeKeyboardObservers()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // keyboard input accessory view support
        textView.inputAccessoryView = UIView(frame: toolbar.bounds)

        // keyboard frame observer
        keyboard
            .toolbar(scrollView: tableView)
            .on(event: .willChangeFrame) { [unowned self] options in
                let height = options.endFrame.height
                UIView.animate(withDuration: 0) {
                    self.bottom.constant = max(0, height - self.toolbar.bounds.height)
                    self.tableView.contentInset.bottom = max(self.toolbar.bounds.height, height)
                    self.tableView.scrollIndicatorInsets.bottom = max(self.toolbar.bounds.height, height)
                    self.toolbar.layoutIfNeeded()
                }
                self.navigationItem.prompt = options.endFrame.debugDescription
            }
            .on(event: .willHide) { [unowned self] options in
                // .willHide is used in cases when keyboard is *not* dismiss interactively.
                // e.g. when `.resignFirstResponder()` is called on textField.
                UIView.animate(withDuration: options.animationDuration, delay: 0, options: UIViewAnimationOptions(curve: options.animationCurve), animations: {
                    self.bottom.constant = 0
                    self.tableView.contentInset.bottom = self.toolbar.bounds.height
                    self.tableView.scrollIndicatorInsets.bottom = self.toolbar.bounds.height
                    self.toolbar.layoutIfNeeded()
                }, completion: nil)
            }
            .start()

        let query = DataSource<Transcript>.Query(self.room.transcripts.reference)
        self.dataSource = query
            .order(by: "createdAt")
            .dataSource()
            .on({ [weak self](snapshot, change) in

                guard let tableView: UITableView = self?.tableView else { return }
                tableView.layoutIfNeeded()
                tableView.reloadData()
//                switch change {
//                case .initial: tableView.reloadData()
//                    print("init")
//                case .update(deletions: let deletions, insertions: let insertions, modifications: let modifications):
//                    tableView.performBatchUpdates({
//                        tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
//                        tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
//                        tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .automatic)
//                    }, completion: { _ in
//
//                    })
//                    if snapshot?.metadata.hasPendingWrites ?? false {
//                        if let count: Int = self?.dataSource?.count {
//                            let indexPath: IndexPath = IndexPath(row: count - 1, section: 0)
//                            tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: true)
//                        }
//                    }
//                case .error(let error): print(error)
//                }
            }).onCompleted({  (_, _) in
//                self?.collectionView.reloadData()
            }).listen()

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
        transcript.text = text
        transcript.room.set((self.room as! Transcript.Room))
        transcript.user.set((self.user as! Transcript.User))
        if let constraint: NSLayoutConstraint = self.constraint {
            textView.removeConstraint(constraint)
        }
        self.toolBar.setNeedsLayout()
        self.room.transcripts.insert(transcript as! Room.Transcript, block: { error in
            print(error)
        })
    }

    // MARK:

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let transcript: Transcript? = self.dataSource?[indexPath.item]
        if transcript?.user.id == self.user.id {
            return MsgRightViewCell.dequeue(from: tableView, for: indexPath, with: .init(transcript: transcript))
        }
        return MsgLeftViewCell.dequeue(from: tableView, for: indexPath, with: .init(transcript: transcript))
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
