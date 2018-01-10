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

public typealias MsgUser = UserProtocol & Document
public typealias MsgRoom = RoomProtocol & Document
public typealias MsgTranscript = TranscriptProtocol & Document

public typealias UserDocument = MsgUser & HasRooms
public typealias RoomDocument = MsgRoom & HasTranscripts

// MARK: User

public protocol UserProtocol {
    var name: String? { get }
    var thumbnail: File? { get }
}

public protocol HasRooms {
    associatedtype Room: RoomDocument
    var rooms: ReferenceCollection<Room> { get }
}

// MARK: Room

public protocol RoomProtocol {
    var name: String? { get }
}

public protocol HasTranscripts {
    associatedtype Transcript: MsgTranscript
    var transcripts: NestedCollection<Transcript> { get }
}

// MARK: Transcript

public protocol TranscriptProtocol {

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

