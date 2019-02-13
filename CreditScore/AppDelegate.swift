//
//  AppDelegate.swift
//  CreditScore
//
//  Created by krawiecp-home on 11/02/2019.
//  Copyright © 2019 pawel. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        if let window = window {
            Application.shared.configure(in: window)
        }
        
        return true
    }
}
