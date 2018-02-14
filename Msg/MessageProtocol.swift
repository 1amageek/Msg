//
//  MessageProtocol.swift
//  Msg
//
//  Created by 1amageek on 2018/02/14.
//  Copyright © 2018年 Stamp Inc. All rights reserved.
//

import FirebaseFirestore
import Pring
import RealmSwift

public protocol MessageProtocol where Sender: RealmSwift.Object {

    associatedtype Transcript: TranscriptDocument
    associatedtype Sender: SenderProtocol

    var id: String { get set }
    var roomID: String { get set }
    var userID: String { get set }
    var createdAt: Date { get set }
    var updatedAt: Date { get set }
    var text: String? { get set }
    var sender: Sender? { get set }

    init(transcript: Transcript)

    static func primaryKey() -> String?
}

public extension MessageProtocol where Self: RealmSwift.Object {

    public init(transcript: Transcript) {
        self.init()
        self.id = transcript.id
        self.roomID = transcript.room.id!
        self.userID = transcript.user.id!
        self.createdAt = transcript.createdAt
        self.updatedAt = transcript.updatedAt
        self.text = transcript.text
    }

    public static func update(id: String, senderID: String) {
        let queue: DispatchQueue = DispatchQueue(label: "message.save.queue")
        queue.async {
            let realm: Realm = try! Realm()
            try! realm.write {
                if var message = realm.objects(Self.self).filter("id == %@", id).first {
                    if let sender = realm.objects(Self.Sender.self).filter("id == %@", senderID).first {

                        message.sender = sender
                        realm.add(message, update: true)
                    }
                }
            }
        }
    }

    public static func saveIfNeeded(transcripts: [Transcript]) {
        let queue: DispatchQueue = DispatchQueue(label: "message.save.queue")
        queue.async {
            let realm: Realm = try! Realm()
            try! realm.write {
                var updateMessages: [Self] = []
                var insertMessages: [Self] = []
                for (_ ,transcript) in Set(transcripts).enumerated() {
                    if let _message = realm.objects(Self.self).filter("id == %@", transcript.id).first {
                        if _message.updatedAt < transcript.updatedAt {
                            let message: Self = Self(transcript: transcript)
                            updateMessages.append(message)
                        }
                    } else {
                        let message: Self = Self(transcript: transcript)
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

    public static func saveIfNeeded(transcript: Transcript, sender: Sender? = nil, realm: Realm = try! Realm()) {
        var message: Self = Self(transcript: transcript)
        if let sender: Sender = sender {
            message.sender = sender
        }
        if let _message = realm.objects(Self.self).filter("id == %@", transcript.id).first {
            if _message.updatedAt < message.updatedAt {
                try! realm.write {
                    realm.add(message, update: true)
                }
            }
        } else {
            try! realm.write {
                realm.add(message, update: true)
            }
        }
    }
}
