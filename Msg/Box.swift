//
//  Msg.swift
//  Msg
//
//  Created by 1amageek on 2018/01/16.
//  Copyright © 2018年 Stamp Inc. All rights reserved.
//

import Foundation
import Pring
import RealmSwift

public class Box<Thread: ThreadProtocol, Sender, Message, Viewer>: NSObject
where
    Thread: RealmSwift.Object,
    Thread.Room == Sender.User.Room, Thread.Room == Message.Transcript.Room, Thread.Message == Message, Thread.Sender == Sender, Thread.Viewer == Viewer,
    Sender.User == Thread.Room.User, Sender.User == Message.Transcript.User,
    Message.Transcript == Thread.Room.Transcript, Message.Transcript == Sender.User.Transcript, Message.Sender == Sender,
    Viewer.User == Sender.User
    {

    public typealias Room = Thread.Room
    public typealias User = Sender.User
    public typealias Transcript = Message.Transcript

    let realm: Realm = try! Realm()

    let dataSource: DataSource<Transcript>

    init(userID: String) {
        let user: User = User(id: userID)
        self.dataSource = DataSource<Transcript>.Query(user.messageMox.reference)
            .order(by: "updatedAt")
            .dataSource()
    }

    private func _updateBadgeCount(_ transcripts: [Transcript]) {
        let queue: DispatchQueue = DispatchQueue(label: ".update.queue")
        queue.async {
            let roomIDs: [String] = transcripts.flatMap { return $0.room.documentReference?.documentID }
            roomIDs.forEach { (id) in
                let filteredTranscripts = transcripts.filter { return $0.room.documentReference?.documentID == id }
                Thread.update(id: id, badgeCount: filteredTranscripts.count)
            }
        }
    }

    public func listen() {
        self.dataSource.on({ [weak self] (_, change) in
            switch change {
            case .initial:
                if let transcripts: [Transcript] = self?.dataSource.documents {
                    Message.saveIfNeeded(transcripts: transcripts)
                }
            case .update(deletions: _, insertions: let insertions, modifications: let modifications):
                if !insertions.isEmpty {
                    let transcripts: [Transcript] = insertions.flatMap { return self?.dataSource[$0] }
                    Message.saveIfNeeded(transcripts: transcripts)
                    self?._updateBadgeCount(transcripts)
                }
                if !modifications.isEmpty {
                    let transcripts: [Transcript] = modifications.flatMap { return self?.dataSource[$0] }
                    Message.saveIfNeeded(transcripts: transcripts)
                }
            case .error(let error): print(error)
            }
        }).listen()
    }

    public class func viewController(userID: String) -> UINavigationController {
        let viewController: ThreadViewController = ThreadViewController(userID: userID)//RoomViewController(userID: userID)
        return UINavigationController(rootViewController: viewController)
    }
}
