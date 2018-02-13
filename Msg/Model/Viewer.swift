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
public class Viewer<User: UserDocument>: RealmSwift.Object {

    public dynamic var userID: String = ""

    public dynamic var threadID: String = ""

    public dynamic var viewedAt: Date = Date()

    public static func saveIfNeeded(users: [User], threadID: String) {
        let queue: DispatchQueue = DispatchQueue(label: "viewer.save.queue")
        queue.async {
            let realm: Realm = try! Realm()
            var updateViewers: [Viewer] = []
            var insertViewers: [Viewer] = []
            for (_, user) in Set(users).enumerated() {
                if let viewer = realm.objects(Viewer.self).filter("userID == %@ && threadID == %@", user.id, threadID).first {
                    if viewer.viewedAt < user.updatedAt {
                        viewer.viewedAt = user.updatedAt
                        updateViewers.append(viewer)
                    }
                } else {
                    let viewer: Viewer = Viewer()
                    viewer.userID = user.id
                    viewer.threadID = threadID
                    insertViewers.append(viewer)
                }
            }
            try! realm.write {
                if !updateViewers.isEmpty {
                    realm.add(updateViewers, update: true)
                }
                if !insertViewers.isEmpty {
                    realm.add(insertViewers, update: true)
                }
            }
        }
    }
}
