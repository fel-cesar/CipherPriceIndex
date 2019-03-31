//
//  MainTabBarViewController.swift
//  Cipher Price Index
//
//  Created by Felipe César Silveira de Assis on 31/03/19.
//  Copyright © 2019 Cipher Studio. All rights reserved.
//

import UIKit
import SwipeableTabBarController

class MainTabBarController: SwipeableTabBarController {
  override func viewDidLoad() {
    super.viewDidLoad()

    self.tabBar.layer.masksToBounds = true
    self.tabBar.isTranslucent = true
    self.tabBar.layer.cornerRadius = 20
    self.tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    self.tabBar.backgroundColor = UIColor.white
    UITabBar.appearance().tintColor = UIColor.darkGray
  }
}
