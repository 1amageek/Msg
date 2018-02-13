//
//  RoomController.swift
//  Msg
//
//  Created by 1amageek on 2018/01/23.
//  Copyright © 2018年 Stamp Inc. All rights reserved.
//

import Foundation
import Pring
import RealmSwift

public extension Box {
    public class RoomController {

        public let userID: String

        public let dataSource: DataSource<Room>

        public let realm: Realm = try! Realm()

        public init(userID: String, limit: Int = 30) {
            self.userID = userID
            let user: User = User(id: userID)
            self.dataSource = DataSource<Room>.Query(user.rooms.reference)
                .order(by: "createdAt")
                .limit(to: limit)
                .dataSource()
        }

        public func listen() {
            self.dataSource.on({ [weak self] (_, change) in
                switch change {
                case .initial:
                    if let rooms: [Room] = self?.dataSource.documents {
                        Thread.saveIfNeeded(rooms: rooms)
                    }
                case .update(deletions: _, insertions: let insertions, modifications: let modifications):
                    if !insertions.isEmpty {
                        let rooms: [Room] = insertions.flatMap { return self?.dataSource[$0] }
                        Thread.saveIfNeeded(rooms: rooms)
                    }
                    if !modifications.isEmpty {
                        let rooms: [Room] = modifications.flatMap { return self?.dataSource[$0] }
                        Thread.saveIfNeeded(rooms: rooms)
                    }
                case .error(let error): print(error)
                }
            }).listen()
        }

        public func next() {
            self.dataSource.next()
        }
    }
}
