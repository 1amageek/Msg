//
//  MsgProtocol.swift
//  Msg
//
//  Created by 1amageek on 2018/01/16.
//  Copyright © 2018年 Stamp Inc. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Pring
import RealmSwift

// Protocol

public typealias MsgUser = UserType & Document
public typealias MsgRoom = RoomType & Document
public typealias MsgTranscript = TranscriptType & Document

public typealias UserProtocol = UserType & HasRooms & HasMessageBox
public typealias RoomProtocol = RoomType & HasTranscripts & HasMembers
public typealias TranscriptProtocol = TranscriptType & HasContent

public typealias UserDocument = UserProtocol & Document
public typealias RoomDocument = RoomProtocol & Document
public typealias TranscriptDocument = TranscriptProtocol & Document


// MARK: User

public protocol UserType {
    var name: String? { get }
    var profileImage: File? { get }
}

public protocol HasMessageBox {
    associatedtype Transcript: MsgTranscript
    var messageMox: ReferenceCollection<Transcript> { get }
}

public protocol HasRooms {
    associatedtype Room: MsgRoom
    var rooms: ReferenceCollection<Room> { get }
}

// MARK: Room

public protocol RoomType {
    var name: String? { get }
}

public protocol HasMembers {
    associatedtype User: UserDocument
    var members: ReferenceCollection<User> { get }
    var viewers: ReferenceCollection<User> { get }
}

extension HasMembers where Self.User.Room == Self {

    public static func create(users: [User], block: ((Error?) -> Void)?) {
        let room: Self = Self()
        users.forEach { (user) in
            room.members.insert(user)
            user.rooms.insert(room)
        }
        room.save { (_, error) in
            block?(error)
        }
    }

    public func join(user: User, block: ((Error?) -> Void)?) {
        self.members.insert(user)
        user.rooms.insert(self)
        self.update { (error) in
            block?(error)
        }
    }
}

public protocol HasTranscripts {
    associatedtype Transcript: TranscriptDocument
    var transcripts: NestedCollection<Transcript> { get }
}

// MARK: Transcript

public protocol TranscriptType {

    associatedtype User: MsgUser
    associatedtype Room: MsgRoom

    var user: Reference<User> { get }
    var room: Reference<Room> { get }
}

public protocol HasContent {

    var text: String? { get set }
    var image: File? { get set }
    var video: File? { get set }
    var audio: File? { get set }
    var location: GeoPoint? { get set }
    var sticker: String? { get set }
    var imageMap: [File] { get set }
}

// MARK: Sender

public protocol SenderProtocol {

    associatedtype User: UserDocument

    var id: String { get set }
    var createdAt: Date { get set }
    var updatedAt: Date { get set }
    var name: String? { get set }
    var profileImageURL: String? { get set }

    init(user: User)

    static func primaryKey() -> String?
}

public extension SenderProtocol where Self: RealmSwift.Object {

    public init(user: User) {
        self.init()
        self.id = user.id
        self.createdAt = user.createdAt
        self.updatedAt = user.updatedAt
        self.name = user.name
        self.profileImageURL = user.profileImage?.downloadURL?.absoluteString
    }

    public static func fetchIfNeeded(id: String, realm: Realm = try! Realm(), block: @escaping (Self?, Error?) -> Void) {
        if let _user = realm.objects(Self.self).filter("id == %@", id).first {
            block(_user, nil)
        } else {
            Self.User.get(id, block: { (user, error) in
                if let error = error {
                    block(nil, error)
                    return
                }
                let _user: Self = Self.saveIfNeeded(user: user!)
                block(_user, nil)
            })
        }
    }

    public static func saveIfNeeded(users: [User], realm: Realm = try! Realm()) {
        var updateMembers: [Self] = []
        var insertMembers: [Self] = []
        users.forEach { (user) in
            let user: Self = Self(user: user)
            if let _user = realm.objects(Self.self).filter("id == %@", user.id).first {
                if _user.updatedAt < user.updatedAt {
                    updateMembers.append(user)
                }
            } else {
                insertMembers.append(user)
            }
        }

        try! realm.write {
            if !updateMembers.isEmpty {
                realm.add(updateMembers, update: true)
            }
            if !insertMembers.isEmpty {
                realm.add(insertMembers, update: true)
            }
        }
    }

    @discardableResult
    public static func saveIfNeeded(user: User, realm: Realm = try! Realm()) -> Self {
        let user: Self = Self(user: user)
        if let _user = realm.objects(Self.self).filter("id == %@", user.id).first {
            if _user.updatedAt < user.updatedAt {
                try! realm.write {
                    realm.add(user, update: true)
                }
            }
        } else {
            try! realm.write {
                realm.add(user, update: true)
            }
        }
        return user
    }
}

// MARK: Thread

public protocol ThreadProtocol where Self.Message: RealmSwift.Object, Self.Sender: RealmSwift.Object {

    associatedtype Room: RoomDocument
    associatedtype Message: MessageProtocol
    associatedtype Sender: SenderProtocol

    var id: String { get set }
    var createdAt: Date { get set }
    var updatedAt: Date { get set }
    var name: String? { get set }
    var thumbnailImageURL: String? { get set }
    var lastMessage: Message? { get set }
    var viewers: List<Sender> { get set }

    init(room: Room)

    static func primaryKey() -> String?
}

public extension ThreadProtocol where Self: RealmSwift.Object {

    public init(room: Room) {
        self.init()
        self.id = room.id
        self.createdAt = room.createdAt
        self.updatedAt = room.updatedAt
        self.name = room.name
    }

    public static func update(id: String, messageID: String) {
        let queue: DispatchQueue = DispatchQueue(label: "thread.save.queue")
        queue.async {
            let realm: Realm = try! Realm()
            if var thread = realm.objects(Self.self).filter("id == %@", id).first {
                if let message = realm.objects(Self.Message.self).filter("id == %@", messageID).first {
                    try! realm.write {
                        thread.lastMessage = message
                        realm.add(thread, update: true)
                    }
                }
            }
        }
    }

    public static func saveIfNeeded(rooms: [Room]) {
        let queue: DispatchQueue = DispatchQueue(label: "thread.save.queue")
        queue.async {
            let realm: Realm = try! Realm()
            var updateThreads: [Self] = []
            var insertThreads: [Self] = []
            rooms.forEach { (room) in
                if let _thread = realm.objects(Self.self).filter("id == %@", room.id).first {
                    if _thread.updatedAt < room.updatedAt {
                        let thread: Self = Self(room: room)
                        updateThreads.append(thread)
                    }
                } else {
                    let thread: Self = Self(room: room)
                    insertThreads.append(thread)
                }
            }

            try! realm.write {
                if !updateThreads.isEmpty {
                    realm.add(updateThreads, update: true)
                }
                if !insertThreads.isEmpty {
                    realm.add(insertThreads, update: true)
                }
            }
        }
    }

    public static func saveIfNeeded(room: Room, realm: Realm = try! Realm()) {
        let thread: Self = Self(room: room)
        if let _thread = realm.objects(Self.self).filter("id == %@", thread.id).first {
            if _thread.updatedAt < thread.updatedAt {
                try! realm.write {
                    realm.add(thread, update: true)
                }
            }
        } else {
            try! realm.write {
                realm.add(thread, update: true)
            }
        }
    }
}

// MARK: Message

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
            if var message = realm.objects(Self.self).filter("id == %@", id).first {
                if let sender = realm.objects(Self.Sender.self).filter("id == %@", senderID).first {
                    try! realm.write {
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
            try! realm.write {
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
