//
//  Message.swift
//  Sample
//
//  Created by 1amageek on 2018/01/16.
//  Copyright © 2018年 Stamp Inc. All rights reserved.
//

import Foundation
import RealmSwift
import Pring

@objcMembers
class Message: RealmSwift.Object, MessageProtocol {

    typealias Transcript = Sample.Transcript

    typealias Sender = Sample.Sender

    dynamic var isLoaded: Bool = false

    dynamic var isRead: Bool = false

    dynamic var id: String = ""

    dynamic var roomID: String = ""

    dynamic var userID: String = ""

    dynamic var createdAt: Date = Date()

    dynamic var updatedAt: Date = Date()

    dynamic var sender: Sender?

    dynamic var text: String?

    dynamic var image: String?

    dynamic var video: String?

    dynamic var audio: String?

    dynamic var location: GeoPoint?

    dynamic var sticker: String?

    public override static func primaryKey() -> String? {
        return "id"
    }
}
