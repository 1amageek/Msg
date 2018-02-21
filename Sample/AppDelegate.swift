//
//  AppDelegate.swift
//  Sample
//
//  Created by 1amageek on 2018/01/17.
//  Copyright © 2018年 Stamp Inc. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var messageBox: Box<Sample.Thread, Sample.Sender, Sample.Message, Sample.Viewer>?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        NSSetUncaughtExceptionHandler { exception in
            debugPrint(exception.name)
            debugPrint(exception.reason ?? "")
            debugPrint(exception.callStackSymbols)
        }

        FirebaseApp.configure()
//        let settings: FirestoreSettings = FirestoreSettings()
//        settings.isPersistenceEnabled = true
//        Firestore.firestore().settings = settings

//        let user0: User = User(id: "hoge")
//        let user1: User = User(id: "fuga")
//        let room: Room = Room()
//
//        user0.name = "hoge"
//        user1.name = "fuga"
//
//        room.members.insert(user0)
//        room.members.insert(user1)
//        user0.rooms.insert(room)
//        user1.rooms.insert(room)
//        room.save()
//        user0.save()
//        user1.save()
//
//        Room.create(name: "ss", userIDs: ["hoge", "fuga"]) { ref, error in
//            print(ref, error)
//        }

        Room
            .where("memberIDs.hoge", isEqualTo: true)
            .where("memberIDs.fuga", isEqualTo: true)
            .get { (snapshot, error) in
            print(snapshot?.documents, error)
        }

        self.messageBox = Box(userID: "hoge")
        self.messageBox?.listen()

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = UINavigationController(rootViewController: Box<Sample.Thread, Sample.Sender, Sample.Message, Sample.Viewer>.threadsController(userID: "hoge"))
        self.window?.makeKeyAndVisible()

        return true
    }
}


