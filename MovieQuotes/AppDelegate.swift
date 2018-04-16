//
//  AppDelegate.swift
//  MovieQuotes
//
//  Created by FengYizhi on 2018/3/27.
//  Copyright © 2018年 FengYizhi. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // DONE: Configure your Firebase project
        FirebaseApp.configure()
        
        return true
    }
}

