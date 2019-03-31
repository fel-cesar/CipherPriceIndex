//
//  ViewController.swift
//  Cipher Price Index
//
//  Created by Felipe César Silveira de Assis on 29/03/19.
//  Copyright © 2019 Cipher Studio. All rights reserved.
//

import UIKit
import RxSwift
import Charts

class ViewController: UIViewController {

  @IBOutlet weak var mainBitcoinPriceLabel: UILabel!

  @IBOutlet weak var lineChart: LineChartView!
  var lineChartEntry = [ChartDataEntry]()

  //Dispose bag
  private let disposeBag = DisposeBag()

  private let apiErrorClosure: (Error) -> Void = { error in
    switch error {
    case ApiError.forbidden:
      print("Forbidden error")
    case ApiError.notFound:
      print("Not found error")
    default:
      print("Unknown error:", error)
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.setupLineChart()
    // Do any additional setup after loading the view.
  }

  //MARK: IBActions
  @IBAction func testButtonAction(_ sender: Any) {

    CoinDeskAPI.getSupportedCurrencies().observeOn(MainScheduler.instance)
      .subscribe(onNext: { currency in
        print(currency.country)
      }, onError: apiErrorClosure )
      .disposed(by: disposeBag)





    let endDate = Date()

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd HH:mm"
//    formatter.timeZone = TimeZone.init(abbreviation: "UTC")
    let startDate = formatter.date(from: "2018/10/08 12:00")

//      ChartDataEntry


//    CoinDeskAPI.getHistorical(currency: "BRL", startDate: startDate, endDate: endDate).observeOn(MainScheduler.instance)
//      .subscribe(onNext: { bitcoinPrices in
//
//        for (bitcoinPrice) in bitcoinPrices {
//          print("List of historical BPis:", bitcoinPrice.date.description, bitcoinPrice.rate)
//
//          // Setting new Data
//          let entry = ChartDataEntry.init(x: Double(self.lineChartEntry.count), y: bitcoinPrice.rate_float)
//          self.lineChartEntry.append(entry)
//
//          let line1 = LineChartDataSet(values: self.lineChartEntry, label: "Number")
//          line1.colors = [NSUIColor.blue]
//          line1.drawCirclesEnabled = false;
//
//          let data = LineChartData()
//          data.addDataSet(line1)
//
//          self.lineChart.data = data
//        }
//
//      }, onError: apiErrorClosure )
//      .disposed(by: disposeBag)


    CoinDeskAPI.getCurrentPrice(currency:"BRL")
    .observeOn(MainScheduler.instance)
    .subscribe(onNext: { currentRate in
      print("List of posts:", currentRate.date)
      self.mainBitcoinPriceLabel.text = currentRate.rate
    }, onError: { error in
      switch error {
      case ApiError.forbidden:
        print("Forbidden error")
      case ApiError.notFound:
        print("Not found error")
      default:
        print("Unknown error:", error)
      }
    })
      .disposed(by: disposeBag)
  }

  private func setupLineChart() {

    self.lineChart.layer.cornerRadius = 30;
    self.lineChart.layer.masksToBounds = true;

    self.lineChart.backgroundColor = NSUIColor.lightGray
    self.lineChart.drawGridBackgroundEnabled = false
    self.lineChart.drawBordersEnabled = false
    self.lineChart.legend.enabled = false

    let xAxis = self.lineChart.xAxis
    xAxis.drawLabelsEnabled = false
    xAxis.drawGridLinesEnabled = false
    xAxis.drawAxisLineEnabled = false
    xAxis.drawLimitLinesBehindDataEnabled = false

    var yAxis = self.lineChart.leftAxis
    yAxis.drawLabelsEnabled = false
    yAxis.drawGridLinesEnabled = false
    yAxis.drawAxisLineEnabled = false
    yAxis.drawLimitLinesBehindDataEnabled = false

    yAxis = self.lineChart.rightAxis
    yAxis.drawLabelsEnabled = false
    yAxis.drawGridLinesEnabled = false
    yAxis.drawAxisLineEnabled = false
    yAxis.drawLimitLinesBehindDataEnabled = false
  }

}

