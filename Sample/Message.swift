//
//  Message.swift
//  Sample
//
//  Created by 1amageek on 2018/01/16.
//  Copyright © 2018年 Stamp Inc. All rights reserved.
//

import RealmSwift
import Pring
import MsgBox

class Message: RealmSwift.Object, MessageProtocol {

    typealias Transcript = Sample.Transcript

    @objc dynamic var id: String = ""

    @objc dynamic var roomID: String = ""

    @objc dynamic var userID: String = ""

    @objc dynamic var createdAt: Date = Date()

    @objc dynamic var updatedAt: Date = Date()

    @objc dynamic var text: String?

    override static func primaryKey() -> String? {
        return "id"
    }

}
