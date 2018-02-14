//
//  ViewController.swift
//  Sample
//
//  Created by 1amageek on 2018/01/17.
//  Copyright © 2018年 Stamp Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var messageBox: Box<Sample.Thread, Sample.Sender, Sample.Message, Sample.Viewer>?

    override func viewDidLoad() {
        super.viewDidLoad()
        let user: User = User()
        user.save { (ref, error) in
            self.messageBox = Box(userID: ref!.documentID)
        }

        // Do any additional setup after loading the view, typically from a nib.
    }
}
