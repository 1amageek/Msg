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
import MsgBox

@objcMembers
class Room: Pring.Object, RoomProtocol {

    typealias Transcript = Sample.Transcript

    var transcripts: SubCollection<Transcript> = []

    dynamic var name: String?
}
