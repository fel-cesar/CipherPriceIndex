//
//  GradientHelper.swift
//  Cipher Price Index
//
//  Created by Felipe César Silveira de Assis on 31/03/19.
//  Copyright © 2019 Cipher Studio. All rights reserved.
//

import UIKit

enum GradientPreset {
  case darkBackground
  case lavander

  var gradient: CAGradientLayer {
    switch self {
    case .darkBackground:
      return CAGradientLayer(start: .topLeft, end: .bottomRight, colors: [
        UIColor.init(red: 54.0/255.0, green: 55.0/255.0, blue: 87.0/255.0, alpha: 1.0).cgColor,
        UIColor.init(red: 38.0/255.0, green: 38.0/255.0, blue: 67.0/255.0, alpha: 1.0).cgColor,
        UIColor.init(red: 21.0/255.0, green: 22.0/255.0, blue: 46.0/255.0, alpha: 1.0).cgColor],
                             type: .axial)
    case .lavander:
      return CAGradientLayer(start: .topLeft, end: .bottomRight, colors: [
        UIColor.init(red: 104.0/255.0, green: 49.0/255.0, blue: 231.0/255.0, alpha: 1.0).cgColor,
        UIColor.init(red: 119.0/255.0, green: 80.0/255.0, blue: 231.0/255.0, alpha: 1.0).cgColor,
        UIColor.init(red: 154.0/255.0, green: 119.0/255.0, blue: 232.0/255.0, alpha: 1.0).cgColor],
                             type: .axial)

    }
  }
}

extension CAGradientLayer {

  enum Point {
    case topLeft
    case centerLeft
    case bottomLeft
    case topCenter
    case center
    case bottomCenter
    case topRight
    case centerRight
    case bottomRight

    var point: CGPoint {
      switch self {
      case .topLeft:
        return CGPoint(x: 0, y: 0)
      case .centerLeft:
        return CGPoint(x: 0, y: 0.5)
      case .bottomLeft:
        return CGPoint(x: 0, y: 1.0)
      case .topCenter:
        return CGPoint(x: 0.5, y: 0)
      case .center:
        return CGPoint(x: 0.5, y: 0.5)
      case .bottomCenter:
        return CGPoint(x: 0.5, y: 1.0)
      case .topRight:
        return CGPoint(x: 1.0, y: 0.0)
      case .centerRight:
        return CGPoint(x: 1.0, y: 0.5)
      case .bottomRight:
        return CGPoint(x: 1.0, y: 1.0)
      }
    }
  }

  convenience init(start: Point, end: Point, colors: [CGColor], type: CAGradientLayerType) {
    self.init()
    self.startPoint = start.point
    self.endPoint = end.point
    self.colors = colors
    self.locations = (0..<colors.count).map(NSNumber.init)
    self.type = type
  }
}
