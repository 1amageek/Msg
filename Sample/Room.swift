//
//  Room.swift
//  Sample
//
//  Created by 1amageek on 2018/01/10.
//  Copyright © 2018年 Stamp Inc. All rights reserved.
//

import Foundation
import Pring
import FirebaseFirestore

@objcMembers
class Room: Object, RoomProtocol {

    typealias Transcript = Sample.Transcript

    typealias User = Sample.User

    var transcripts: NestedCollection<Transcript> = []

    var memberIDs: Set<String> = []

    var members: ReferenceCollection<User> = []

    var viewers: ReferenceCollection<User> = []

    dynamic var name: String?
}
