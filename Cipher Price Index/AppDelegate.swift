//
//  AppDelegate.swift
//  Cipher Price Index
//
//  Created by Felipe César Silveira de Assis on 29/03/19.
//  Copyright © 2019 Cipher Studio. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Check if there is a default coin
    let currency = UserDefaults.standard.string(forKey: "SelectedCurrency")
    if  currency == nil {
      print("Currency nil, setting default")
      UserDefaults.standard.set("USD", forKey: "SelectedCurrency")
    }
    return true
  }
}

