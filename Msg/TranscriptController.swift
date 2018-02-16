//
//  TranscriptController.swift
//  Msg
//
//  Created by 1amageek on 2018/01/23.
//  Copyright © 2018年 Stamp Inc. All rights reserved.
//

import Foundation
import Pring
import RealmSwift

public extension Box {
    public class TranscriptController {

        public let roomID: String

        public let dataSource: DataSource<Transcript>

        public let realm: Realm = try! Realm()

        public let viewers: DataSource<User>

        public init(roomID: String, limit: Int = 30) {
            self.roomID = roomID
            let room: Room = Room(id: roomID)
            self.viewers = room.viewers.query.dataSource()
            self.dataSource = DataSource<Transcript>.Query(room.transcripts.reference)
                .order(by: "createdAt")
                .limit(to: limit)
                .dataSource()
        }

        public func listen() {

            let roomID: String = self.roomID

            self.viewers.on { [weak self] (_, change) in
                switch change {
                case .initial:
                    if let users: [User] = self?.viewers.documents {
                        Viewer.saveIfNeeded(users: users, threadID: roomID)
                    }
                case .update(deletions: _, insertions: let insertions, modifications: let modifications):
                    if !insertions.isEmpty {
                        let users: [User] = insertions.flatMap { return self?.viewers[$0] }
                        Viewer.saveIfNeeded(users: users, threadID: roomID)
                    }
                    if !modifications.isEmpty {
                        let users: [User] = modifications.flatMap { return self?.viewers[$0] }
                        Viewer.saveIfNeeded(users: users, threadID: roomID)
                    }
                case .error(let error): print(error)
                }
            }.listen()

            self.dataSource.on { [weak self] (_, change) in
                switch change {
                case .initial:
                    if let transcripts: [Transcript] = self?.dataSource.documents {
                        Message.saveIfNeeded(transcripts: transcripts, isRead: true)
                    }
                case .update(deletions: _, insertions: let insertions, modifications: let modifications):
                    if !insertions.isEmpty {
                        let transcripts: [Transcript] = insertions.flatMap { return self?.dataSource[$0] }
                        Message.saveIfNeeded(transcripts: transcripts, isRead: true)
                    }
                    if !modifications.isEmpty {
                        let transcripts: [Transcript] = modifications.flatMap { return self?.dataSource[$0] }
                        Message.saveIfNeeded(transcripts: transcripts, isRead: true)
                    }
                case .error(let error): print(error)
                }
            }.listen()
        }

        private func _saveIfNeeded(transcripts: [Transcript]) {
            let queue: DispatchQueue = DispatchQueue(label: "message.update.queue")
            queue.async {
                let realm: Realm = try! Realm()
                try! realm.write {
                    var updateMessages: [Message] = []
                    var insertMessages: [Message] = []
                    for (_ ,transcript) in Set(transcripts).enumerated() {
                        if let _message = realm.objects(Message.self).filter("id == %@", transcript.id).first {
                            if _message.updatedAt < transcript.updatedAt {
                                var message: Message = Message(transcript: transcript)
                                message.isRead = true
                                updateMessages.append(message)
                            }
                        } else {
                            var message: Message = Message(transcript: transcript)
                            message.isRead = true
                            insertMessages.append(message)
                        }
                    }

                    if !updateMessages.isEmpty {
                        realm.add(updateMessages, update: true)
                    }
                    if !insertMessages.isEmpty {
                        realm.add(insertMessages, update: true)
                    }
                }
            }
        }

        public func next() {
            self.dataSource.next()
        }

        public func fetchMembers(_ block: ((Error?) -> Void)?) {
            let room: Room = Room(id: roomID)
            room.members
                .query
                .dataSource()
                .onCompleted { [weak self] (_, users) in
                    guard let realm: Realm = self?.realm else { return }
                    if !users.isEmpty {
                        Sender.saveIfNeeded(users: users, realm: realm)
                    }
                }.get()
        }
    }
}
