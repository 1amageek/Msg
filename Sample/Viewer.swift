//
//  Viewer.swift
//  Msg
//
//  Created by 1amageek on 2018/02/01.
//  Copyright © 2018年 Stamp Inc. All rights reserved.
//

import Foundation
import RealmSwift
import Pring

@objcMembers
class Viewer: RealmSwift.Object, ViewerProtocol {

    typealias User = Sample.User

    dynamic var id: String = ""

    dynamic var userID: String = ""

    dynamic var viewedAt: Date = Date()

    public override static func primaryKey() -> String? {
        return "id"
    }
}
