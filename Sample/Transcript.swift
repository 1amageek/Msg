//
//  Transcript.swift
//  Sample
//
//  Created by 1amageek on 2018/01/10.
//  Copyright © 2018年 Stamp Inc. All rights reserved.
//

import Foundation
import Pring
import FirebaseFirestore

@objcMembers
class Transcript: Object, TranscriptProtocol {

    typealias User = Sample.User

    typealias Room = Sample.Room

    override class var shouldBeReplicated: Bool { return true }

    var sender: Reference<User> = .init()

    var room: Reference<Room>  = .init()

    dynamic var text: String?

    dynamic var image: File?

    dynamic var video: File?

    dynamic var audio: File?

    dynamic var location: FirebaseFirestore.GeoPoint?

    dynamic var sticker: String?

    dynamic var imageMap: [File] = []

}
