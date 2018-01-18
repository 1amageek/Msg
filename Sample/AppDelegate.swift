//
//  AppDelegate.swift
//  Sample
//
//  Created by 1amageek on 2018/01/10.
//  Copyright © 2018年 Stamp Inc. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


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

        let user: User = User(id: "B25fLWWUY5XdU9Ir9rYl")
        let room: Room = Room(id: "G5WZK9Ek3vIcwDey0yXP")
//        user.rooms.insert(room)
//        user.save()

        let viewController: MsgViewController<User, Room, Transcript, Message> = MsgViewController<User, Room, Transcript, Message>(roomID: "G5WZK9Ek3vIcwDey0yXP", userID: "B25fLWWUY5XdU9Ir9rYl")
////        let viewController: MsgViewController = MsgViewController()

        let navigationController = UINavigationController(rootViewController: viewController)

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()

        return true
    }
}

