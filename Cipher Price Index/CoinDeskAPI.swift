//
//  CoinDeskAPI.swift
//  Cipher Price Index
//
//  Created by Felipe César Silveira de Assis on 29/03/19.
//  Copyright © 2019 Cipher Studio. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import SwiftyJSON

enum ApiError: Error {
  case notFound
  case internalServerError
  case forbidden
  case badResponse // Unable to parse response
}

enum CoinDeskApiDateFormat: String {
  case updatedISO = "yyyy-MM-dd'T'HH:mm:ssZ"
  case history = "yyyy-MM-dd"
}

class CoinDeskAPI {

  //The API's base URL
  static let baseUrl = "https://api.coindesk.com/v1/bpi"
  class func getHistorical(currency:String, startDate: Date? = nil, endDate: Date? = nil) -> Observable<[BitcoinPrice]> {
    var url = "\(baseUrl)/historical/close.json?currency=\(currency)"

    if (startDate != nil && endDate != nil) {
      // Adding Date to object
      let dateFormaterISO = DateFormatter()
      dateFormaterISO.dateFormat = CoinDeskApiDateFormat.history.rawValue
      url += "&start=" + dateFormaterISO.string(from: startDate!)
      url += "&end=" + dateFormaterISO.string(from: endDate!)
      print(url)
    }

    return CoinDeskAPI.getRequest(url: url) { (observer, response) in

      guard let data = response.data else {
        observer.onError(ApiError.badResponse)
        return
      }

      do {
        let json = try JSON(data: data)
        guard let bpiList = json["bpi"].dictionaryObject as? [String:Double] else {
          throw ApiError.badResponse
        }

        var bpis: [BitcoinPrice] = []

        for (dateString, price) in bpiList {

          // Formating properly the rate
          let rateFormatter = NumberFormatter.init()
          rateFormatter.numberStyle = .decimal
          guard let rate = rateFormatter.string(from: NSNumber(value: price)) else {
            throw ApiError.badResponse
          }

          // Adding Date to object
          let dateFormaterISO = DateFormatter()
          dateFormaterISO.dateFormat = CoinDeskApiDateFormat.history.rawValue

          guard let date = dateFormaterISO.date(from: dateString) else {
            print("Couldnt parse \(dateString)")
            continue
          }

          let bitcoinPrice = BitcoinPrice.init(code: currency,
                                               coinDescription: "",
                                               rate: rate,
                                               rate_float: price,
                                               date: date)
          bpis.append(bitcoinPrice)
        }
        observer.onNext(bpis.sorted(by: {
           $0.date.compare($1.date) == .orderedDescending
        }))
        observer.onCompleted()
      } catch {
        observer.onError(error)
      }

    } as Observable<[BitcoinPrice]>
  }


  class func getCurrentPrice(currency:String = "USD") -> Observable<BitcoinPrice>{

    return Observable<BitcoinPrice>.create { observer in

      let request = Alamofire.request("\(baseUrl)/currentprice/\(currency)").responseJSON { response in


        //Check the result from Alamofire's response and check if it's a success or a failure
        switch response.result {
        case .success:
          if let data = response.data {
            do {
              let json = try JSON(data: data)
              let coinBP = json["bpi"][currency]
              let code = coinBP["code"].string!
              let description = coinBP["description"].string!
              let rate = coinBP["rate"].string!
              let rateFloat = coinBP["rate_float"].floatValue

              //Adding Date to object
              let dateFormaterISO = DateFormatter()
              dateFormaterISO.dateFormat = CoinDeskApiDateFormat.updatedISO.rawValue
              guard let date = dateFormaterISO.date(from: json["time"]["updatedISO"].string!) else {
                throw ApiError.internalServerError
              }

              let bitcoinPrice = BitcoinPrice.init(code: code,
                                                   coinDescription: description,
                                                   rate: rate,
                                                   rate_float: Double.init(rateFloat),
                                                   date: date)

              observer.onNext(bitcoinPrice);
              observer.onCompleted()
            } catch {
              observer.onError(error)
            }
          }

        case .failure(let error):
          switch response.response?.statusCode {
          case 403:
            observer.onError(ApiError.forbidden)
          case 404:
            observer.onError(ApiError.notFound)
          case 500:
            observer.onError(ApiError.internalServerError)
          default:
            observer.onError(error)
          }
        }
      }

      return Disposables.create {
        request.cancel()
      }
    }
  }


  class func getRequest<T>(url: URLConvertible, success: @escaping (_ observer: AnyObserver<T>,_ response:DataResponse<Any>) -> () ) ->Observable<T> {

    return Observable<T>.create { observer in

      let request = Alamofire.request(url).responseJSON { response in

        //Check the result from Alamofire's response and check if it's a success or a failure
        switch response.result {
        case .success:
          success(observer, response)
        case .failure(let error):
          switch response.response?.statusCode {
          case 403:
            observer.onError(ApiError.forbidden)
          case 404:
            observer.onError(ApiError.notFound)
          case 500:
            observer.onError(ApiError.internalServerError)
          default:
            observer.onError(error)
          }
        }
      }

      //Finally, we return a disposable to stop the request
      return Disposables.create {
        request.cancel()
      }
    }
  }


}
