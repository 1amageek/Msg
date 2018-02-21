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

    public let dataSource: DataSource<Transcript>

    public init(userID: String) {
        let user: User = User(id: userID)
        self.dataSource = DataSource<Transcript>.Query(user.messageBox.reference)
            .order(by: "updatedAt")
            .dataSource()
    }

    public func listen() {
        self.dataSource
            .on({ [weak self] (_, change) in
            switch change {
            case .initial:
                if let transcripts: [Transcript] = self?.dataSource.documents {
                    Message.saveIfNeeded(transcripts: transcripts)
                }
            case .update(deletions: _, insertions: let insertions, modifications: let modifications):
                if !insertions.isEmpty {
                    let transcripts: [Transcript] = insertions.flatMap { return self?.dataSource[$0] }
                    Message.saveIfNeeded(transcripts: transcripts)
                }
                if !modifications.isEmpty {
                    let transcripts: [Transcript] = modifications.flatMap { return self?.dataSource[$0] }
                    Message.saveIfNeeded(transcripts: transcripts)
                }
//                if !deletions.isEmpty {
//                    let transcripts: [Transcript] = deletions.flatMap { return self?.dataSource[$0] }
//                }
            case .error(let error): print(error)
            }
        }).listen()
    }

    public class func threadsController(userID: String) -> ThreadViewController {
        return ThreadViewController(userID: userID)
    }

    public class func messagesController(roomID: String, userID: String) -> MessageViewController {
        return MessageViewController(roomID: roomID, userID: userID)
    }
}
