//
//  BitCoinPriceView.swift
//  Cipher Price Index
//
//  Created by Felipe César Silveira de Assis on 30/03/19.
//  Copyright © 2019 Cipher Studio. All rights reserved.
//

import Foundation

class BitcoinPriceView {

  private let bitcoinPrice: BitcoinPrice

   init(bitcoinPrice: BitcoinPrice) {
    self.bitcoinPrice = bitcoinPrice
  }

  public var dateText: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd-MM-yyyy"
    return dateFormatter.string(from: self.bitcoinPrice.date)
  }

  public var valueText: String {
    return self.bitcoinPrice.rate
  }

}
