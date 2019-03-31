//
//  Currency.swift
//  Cipher Price Index
//
//  Created by Felipe César Silveira de Assis on 31/03/19.
//  Copyright © 2019 Cipher Studio. All rights reserved.
//

import Foundation

class Currency {
  let code: String
  let country: String

  init(code: String, country: String) {
    self.code = code
    self.country = country
  }
}
