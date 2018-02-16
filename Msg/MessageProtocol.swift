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

@objcMembers
public class GeoPoint: RealmSwift.Object {

    public dynamic var latitude: Double = 0

    public dynamic var longitude: Double = 0

    public convenience init(_ location: FirebaseFirestore.GeoPoint) {
        self.init()
        self.latitude = location.latitude
        self.longitude = location.longitude
    }
}

public protocol MessageProtocol where Sender: RealmSwift.Object {

    associatedtype Transcript: TranscriptDocument
    associatedtype Sender: SenderProtocol

    var id: String { get set }
    var roomID: String { get set }
    var userID: String { get set }
    var sender: Sender? { get set }
    var createdAt: Date { get set }
    var updatedAt: Date { get set }

    // Contents
    var text: String? { get set }
    var image: String? { get set }
    var video: String? { get set }
    var audio: String? { get set }
    var location: GeoPoint? { get set }
    var sticker: String? { get set }
//    var imageMap: [String] { get set }

    var isLoaded: Bool { get set }
    var isRead: Bool { get set }

    init(transcript: Transcript)

    static func primaryKey() -> String?
}

public extension MessageProtocol where Self: RealmSwift.Object {

    public init(transcript: Transcript) {
        self.init()
        self.id = transcript.id

        // RoomID
        if let roomID: String = transcript.room.id {
            self.roomID = roomID
        }

        // UserID
        if let userID: String = transcript.user.id {
            self.userID = userID
        }

        self.createdAt = transcript.createdAt
        self.updatedAt = transcript.updatedAt
        self.text = transcript.text
        self.image = transcript.image?.downloadURL?.absoluteString
        self.video = transcript.video?.downloadURL?.absoluteString
        self.audio = transcript.audio?.downloadURL?.absoluteString
        if let location: FirebaseFirestore.GeoPoint = transcript.location {
            self.location = GeoPoint(location)
        }
        self.sticker = transcript.sticker
//        self.imageMap = transcript.imageMap
        self.isLoaded = transcript.hasContents
    }

//    public static func update(id: String, senderID: String) {
//        let queue: DispatchQueue = DispatchQueue(label: "message.save.queue")
//        queue.async {
//            let realm: Realm = try! Realm()
//            try! realm.write {
//                if var message = realm.objects(Self.self).filter("id == %@", id).first {
//                    if let sender = realm.objects(Self.Sender.self).filter("id == %@", senderID).first {
//                        message.sender = sender
//                        realm.add(message, update: true)
//                    }
//                }
//            }
//        }
//    }

    public static func saveIfNeeded(transcripts: [Transcript], isRead: Bool = false) {
        let queue: DispatchQueue = DispatchQueue(label: "message.save.queue")
        queue.async {
            let realm: Realm = try! Realm()
            try! realm.write {
                var updateMessages: [Self] = []
                var insertMessages: [Self] = []
                for (_ ,transcript) in Set(transcripts).enumerated() {
                    if let _message = realm.objects(Self.self).filter("id == %@", transcript.id).first {
                        if _message.updatedAt < transcript.updatedAt {
                            var message: Self = Self(transcript: transcript)
                            message.isRead = _message.isRead ? true : isRead
                            updateMessages.append(message)
                        }
                    } else {
                        var message: Self = Self(transcript: transcript)
                        message.isRead = isRead
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
}
