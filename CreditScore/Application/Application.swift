//
//  Application.swift
//  CreditScore
//
//  Created by krawiecp-home on 11/02/2019.
//  Copyright © 2019 pawel. All rights reserved.
//

import UIKit

// Decoupling code from AppDelegate so it's nice and short
final class Application {
    static let shared = Application() // Singleton! UIApplication is singleton itself
    // so I think it's fine to use it
    
    func configure(in window: UIWindow) {
        let dashboardViewModel = DashboardViewModel()
        let dashboardViewController = DashboardViewController(viewModel: dashboardViewModel)
        
        window.rootViewController = UINavigationController(rootViewController: dashboardViewController)
        window.makeKeyAndVisible()
    }
}
