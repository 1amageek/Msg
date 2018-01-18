//
//  Transcript.swift
//  Sample
//
//  Created by 1amageek on 2018/01/10.
//  Copyright © 2018年 Stamp Inc. All rights reserved.
//

import RealmSwift
import Pring
import MsgBox
import FirebaseFirestore

@objcMembers
class Transcript: Pring.Object, TranscriptProtocol {

    typealias User = Sample.User

    typealias Room = Sample.Room

    var user: Reference<User> = .init()

    var room: Reference<Room>  = .init()

    dynamic var text: String?

    dynamic var image: File?

    dynamic var video: File?

    dynamic var audio: File?

    dynamic var location: GeoPoint?

    dynamic var sticker: String?

    dynamic var imageMap: [File] = []
}
