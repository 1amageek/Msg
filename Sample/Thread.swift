//
//  Thread.swift
//  Sample
//
//  Created by 1amageek on 2018/01/30.
//  Copyright © 2018年 Stamp Inc. All rights reserved.
//

import Foundation
import RealmSwift
import Pring

@objcMembers
class Thread: RealmSwift.Object, ThreadProtocol {

    typealias Room = Sample.Room

    typealias Message = Sample.Message

    typealias Sender = Sample.Sender

    typealias Viewer = Sample.Viewer

    dynamic var id: String = ""

    dynamic var createdAt: Date = Date()

    dynamic var updatedAt: Date = Date()

    dynamic var name: String?

    dynamic var thumbnailImageURL: String?

    dynamic var lastMessage: Message?

    dynamic var viewers: List<Viewer> = .init()
    
    public override static func primaryKey() -> String? {
        return "id"
    }
}
