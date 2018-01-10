//
//  Msg.swift
//  Msg
//
//  Created by 1amageek on 2018/01/10.
//  Copyright © 2018年 Stamp Inc. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Pring

public typealias MsgUser = UserDocument & Document
public typealias MsgRoom = RoomDocumet & Document
public typealias MsgTranscript = TranscriptDocument & Document

public typealias UserProtocol = MsgUser & HasRooms
public typealias RoomProtocol = MsgRoom & HasTranscripts
public typealias TranscriptProtocol = MsgTranscript & HasContent

// MARK: User

public protocol UserDocument {
    var name: String? { get }
    var thumbnail: File? { get }
}

public protocol HasRooms {
    associatedtype Room: RoomProtocol
    var rooms: ReferenceCollection<Room> { get }
}

// MARK: Room

public protocol RoomDocumet {
    var name: String? { get }
}

public protocol HasTranscripts {
    associatedtype Transcript: MsgTranscript
    var transcripts: NestedCollection<Transcript> { get }
}

// MARK: Transcript

public protocol TranscriptDocument {

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

