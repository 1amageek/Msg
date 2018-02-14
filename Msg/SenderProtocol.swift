//
//  SenderProtocol.swift
//  Msg
//
//  Created by 1amageek on 2018/02/14.
//  Copyright © 2018年 Stamp Inc. All rights reserved.
//

import FirebaseFirestore
import Pring
import RealmSwift

public protocol SenderProtocol {

    associatedtype User: UserDocument

    var id: String { get set }
    var createdAt: Date { get set }
    var updatedAt: Date { get set }
    var name: String? { get set }
    var profileImageURL: String? { get set }

    init(user: User)

    static func primaryKey() -> String?
}

public extension SenderProtocol where Self: RealmSwift.Object {

    public init(user: User) {
        self.init()
        self.id = user.id
        self.createdAt = user.createdAt
        self.updatedAt = user.updatedAt
        self.name = user.name
        self.profileImageURL = user.profileImage?.downloadURL?.absoluteString
    }

    public static func fetchIfNeeded(id: String, realm: Realm = try! Realm(), block: @escaping (Self?, Error?) -> Void) {
        if let _user = realm.objects(Self.self).filter("id == %@", id).first {
            block(_user, nil)
        } else {
            Self.User.get(id, block: { (user, error) in
                if let error = error {
                    block(nil, error)
                    return
                }
                let _user: Self = Self.saveIfNeeded(user: user!)
                block(_user, nil)
            })
        }
    }

    public static func saveIfNeeded(users: [User], realm: Realm = try! Realm()) {
        var updateMembers: [Self] = []
        var insertMembers: [Self] = []
        users.forEach { (user) in
            let user: Self = Self(user: user)
            if let _user = realm.objects(Self.self).filter("id == %@", user.id).first {
                if _user.updatedAt < user.updatedAt {
                    updateMembers.append(user)
                }
            } else {
                insertMembers.append(user)
            }
        }

        try! realm.write {
            if !updateMembers.isEmpty {
                realm.add(updateMembers, update: true)
            }
            if !insertMembers.isEmpty {
                realm.add(insertMembers, update: true)
            }
        }
    }

    @discardableResult
    public static func saveIfNeeded(user: User, realm: Realm = try! Realm()) -> Self {
        let user: Self = Self(user: user)
        if let _user = realm.objects(Self.self).filter("id == %@", user.id).first {
            if _user.updatedAt < user.updatedAt {
                try! realm.write {
                    realm.add(user, update: true)
                }
            }
        } else {
            try! realm.write {
                realm.add(user, update: true)
            }
        }
        return user
    }
}
