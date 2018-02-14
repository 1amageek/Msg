//
//  ThreadProtocol.swift
//  Msg
//
//  Created by 1amageek on 2018/02/14.
//  Copyright © 2018年 Stamp Inc. All rights reserved.
//

import FirebaseFirestore
import Pring
import RealmSwift

public protocol ThreadProtocol where Self.Message: RealmSwift.Object, Self.Sender: RealmSwift.Object, Self.Viewer: RealmSwift.Object {

    associatedtype Room: RoomDocument
    associatedtype Message: MessageProtocol
    associatedtype Sender: SenderProtocol
    associatedtype Viewer: ViewerProtocol

    var id: String { get set }
    var createdAt: Date { get set }
    var updatedAt: Date { get set }
    var name: String? { get set }
    var thumbnailImageURL: String? { get set }
    var lastMessage: Message? { get set }
    var viewers: List<Viewer> { get set }

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
