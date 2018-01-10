//
//  Room.swift
//  Sample
//
//  Created by 1amageek on 2018/01/10.
//  Copyright © 2018年 Stamp Inc. All rights reserved.
//

import Foundation
import Pring

@objcMembers
class Room: Object, RoomProtocol {

    typealias Transcript = Sample.Transcript

    var transcripts: NestedCollection<Transcript> = []

    dynamic var name: String?
}
