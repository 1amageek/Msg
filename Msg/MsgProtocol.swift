//
//  MsgProtocol.swift
//  Msg
//
//  Created by 1amageek on 2018/01/16.
//  Copyright © 2018年 Stamp Inc. All rights reserved.
//

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
    var name: String? { get set }
}

public protocol HasMembers {
    associatedtype User: UserDocument
    var members: ReferenceCollection<User> { get }
    var viewers: ReferenceCollection<User> { get }
}

extension HasMembers where Self.User.Room == Self {

    public static func create(name: String?, userIDs: [String], block: ((DocumentReference?, Error?) -> Void)? = nil) {
        var room: Self = Self()
        room.name = name
        userIDs.forEach { (userID) in
            let user: User = User(id: userID, value: [:])
            room.members.insert(user)
            user.rooms.insert(room)
        }
        room.save(block)
    }

    public func join(userIDs: [String], block: ((Error?) -> Void)? = nil) {
        userIDs.forEach { (userID) in
            let user: User = User(id: userID, value: [:])
            self.members.insert(user)
            user.rooms.insert(self)
        }
        self.update(block)
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

    static var shouldBeReplicated: Bool { get }
}

public extension TranscriptType {
    static var shouldBeReplicated: Bool { return true }
}

public protocol HasContent {

    var text: String? { get set }
    var image: File? { get set }
    var video: File? { get set }
    var audio: File? { get set }
    var location: FirebaseFirestore.GeoPoint? { get set }
    var sticker: String? { get set }
    var imageMap: [File] { get set }

    var hasContents: Bool { get }
}

public extension HasContent {
    var hasContents: Bool {
        if
            self.text != nil ||
            self.image != nil ||
            self.video != nil ||
            self.audio != nil ||
            self.location != nil ||
            self.sticker != nil ||
            !self.imageMap.isEmpty {
            return true
        }
        return false
    }
}
