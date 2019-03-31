//
//  BitcoinPrice.swift
//  Cipher Price Index
//
//  Created by Felipe César Silveira de Assis on 30/03/19.
//  Copyright © 2019 Cipher Studio. All rights reserved.
//

import Foundation

class BitcoinPrice: Codable {
  let code: String
  let coinDescription: String
  let rate:String
  let rate_float: Double
  let date: Date

  init(code: String, coinDescription: String, rate:String, rate_float: Double, date: Date) {
    self.code = code;
    self.coinDescription = coinDescription
    self.rate = rate
    self.rate_float = rate_float
    self.date = date
  }
}
