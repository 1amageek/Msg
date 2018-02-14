//
//  ViewerProtocol.swift
//  Msg
//
//  Created by 1amageek on 2018/02/14.
//  Copyright © 2018年 Stamp Inc. All rights reserved.
//

import FirebaseFirestore
import Pring
import RealmSwift

public protocol ViewerProtocol {

    associatedtype User: UserDocument

    var id: String { get set }
    var userID: String { get set }
    var viewedAt: Date { get set }

    static func primaryKey() -> String?
}

public extension ViewerProtocol where Self: RealmSwift.Object {

    public static func saveIfNeeded(users: [User], threadID: String) {
        let queue: DispatchQueue = DispatchQueue(label: "viewer.save.queue")
        queue.async {
            let realm: Realm = try! Realm()
            try! realm.write {
                var updateViewers: [Self] = []
                var insertViewers: [Self] = []
                for (_, user) in Set(users).enumerated() {
                    let id: String = "\(user.id)\(threadID)"
                    if var viewer = realm.objects(Self.self).filter("id == %@", id).first {
                        if viewer.viewedAt < user.updatedAt {
                            viewer.viewedAt = user.updatedAt
                            updateViewers.append(viewer)
                        }
                    } else {
                        var viewer: Self = Self()
                        viewer.id = id
                        viewer.userID = user.id
                        viewer.viewedAt = user.updatedAt
                        insertViewers.append(viewer)
                    }
                }

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
