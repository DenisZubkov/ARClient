//
//  AppDelegate.swift
//  ARClient
//
//  Created by Dennis Zubkoff on 01.02.2020.
//  Copyright © 2020 Denis Zubkov. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    
}


extension AppDelegate {
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    var rootViewController: LoadViewController {
        
        return window!.rootViewController as! LoadViewController
    }
}
