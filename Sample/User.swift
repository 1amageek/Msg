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
import MsgBox

@objcMembers
class User: Pring.Object, UserProtocol {

    typealias Transcript = Sample.Transcript

    typealias Room = Sample.Room

    dynamic var name: String?

    dynamic var thumbnail: File?

    var rooms: SubCollection<Room> = []

    var messageMox: ReferenceCollection<Transcript> = []
}
