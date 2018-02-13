//
//  User.swift
//  Sample
//
//  Created by 1amageek on 2018/01/10.
//  Copyright © 2018年 Stamp Inc. All rights reserved.
//

import Foundation
import Pring
import FirebaseFirestore

@objcMembers
class User: Object, UserProtocol {

    typealias Transcript = Sample.Transcript

    typealias Room = Sample.Room

    dynamic var name: String?

    dynamic var profileImage: File?

    var rooms: ReferenceCollection<Room> = []

    var messageMox: ReferenceCollection<Transcript> = []
}
