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
