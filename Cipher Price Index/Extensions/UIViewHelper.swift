//
//  UIViewHelper.swift
//  Cipher Price Index
//
//  Created by Felipe César Silveira de Assis on 31/03/19.
//  Copyright © 2019 Cipher Studio. All rights reserved.
//

import UIKit

extension UIView {
  func fadeTransition(_ duration:CFTimeInterval) {
    let animation = CATransition()
    animation.timingFunction = CAMediaTimingFunction(name:
      CAMediaTimingFunctionName.easeInEaseOut)
    animation.type = CATransitionType.fade
    animation.duration = duration
    layer.add(animation, forKey: CATransitionType.fade.rawValue)
  }
}
