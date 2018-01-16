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

public typealias MsgUser = UserType & Document
public typealias MsgRoom = RoomType & Document

public typealias UserProtocol = UserType & HasRooms
public typealias RoomProtocol = RoomType & HasTranscripts
public typealias TranscriptProtocol = TranscriptType & HasContent

public typealias UserDocument = UserProtocol & Document
public typealias RoomDocument = RoomProtocol & Document
public typealias TranscriptDocument = TranscriptType & HasContent & Document


// MARK: User

public protocol UserType {
    var name: String? { get }
    var thumbnail: File? { get }
}

public protocol HasRooms {
    associatedtype Room: MsgRoom
    var rooms: SubCollection<Room> { get }
}

// MARK: Room

public protocol RoomType {
    var name: String? { get }
}

public protocol HasTranscripts {
    associatedtype Transcript: TranscriptDocument
    var transcripts: SubCollection<Transcript> { get }
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

