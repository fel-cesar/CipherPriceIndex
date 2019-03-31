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
  @IBOutlet weak var currencyButton: UIButton!
  @IBOutlet weak var lineChartBackground: UIView!
  @IBOutlet weak var mainValuebackgroundView: UIView!
  @IBOutlet weak var currencyLabel: UILabel!

  var lineChartEntry = [ChartDataEntry]()

  // Dispose bag
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

    setupView()
    setupInitialObservers()


    self.setupLineChart()
    // Do any additional setup after loading the view.
  }

  // MARK: IBActions
  @IBAction func currencyButtonAction(_ sender: Any) {
    self.performSegue(withIdentifier: "toCurrencySelect", sender: self)
  }

  // MARK: Helper Methods
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  private func setupInitialObservers() {

    // Main label every time the currency is changed
    UserDefaults.standard.rx
      .observe(String.self, "SelectedCurrency")
      .debounce(0.1, scheduler: MainScheduler.asyncInstance).subscribe(onNext: { (value) in
        if let value = value {
          self.currencyLabel.text = value
          CoinDeskAPI.getCurrentPrice(currency:value)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { currentRate in
              self.mainBitcoinPriceLabel.fadeTransition(0.5)
              self.mainBitcoinPriceLabel.text = currentRate.rate
            }, onError: self.apiErrorClosure )
            .disposed(by: self.disposeBag)

          // Update main Graph
          CoinDeskAPI.getHistorical(currency: value).observeOn(MainScheduler.instance)
            .subscribe(onNext: { bitcoinPrices in

              self.lineChartEntry.removeAll()
              for (bitcoinPrice) in bitcoinPrices {
                print("List of historical BPis:", bitcoinPrice.date.description, bitcoinPrice.rate)

                let entry = ChartDataEntry.init(x: Double(self.lineChartEntry.count), y: bitcoinPrice.rate_float)
                self.lineChartEntry.append(entry)

                let line = LineChartDataSet(values: self.lineChartEntry, label: "Number")
                line.colors = [NSUIColor.white]
                line.drawCirclesEnabled = false;
                line.lineWidth = 3
                line.lineCapType = CGLineCap.round
                line.valueTextColor = .clear

                let data = LineChartData()
                data.addDataSet(line)
                self.lineChart.data = data
              }

            }, onError: self.apiErrorClosure)
            .disposed(by: self.disposeBag)

        }
      }).disposed(by: disposeBag)
  }

  private func setupView() {

    // Creating Gradient Background
    let gradient = GradientPreset.darkBackground.gradient

    gradient.frame = view.bounds
    view.layer.insertSublayer(gradient, at: 0)

    // Creating gradient background for main value
    let gradientSmall = GradientPreset.lavander.gradient

    gradientSmall.frame = self.mainValuebackgroundView.bounds
    self.mainValuebackgroundView.layer.insertSublayer(gradientSmall, at: 0)
    self.mainValuebackgroundView.layer.cornerRadius = 30;
    self.mainValuebackgroundView.layer.masksToBounds = true;
  }

  private func setupLineChart() {

    let gradient = GradientPreset.lavander.gradient

    gradient.frame = self.lineChartBackground.bounds
    self.lineChartBackground.layer.insertSublayer(gradient, at: 0)
    self.lineChartBackground.layer.cornerRadius = 30;
    self.lineChartBackground.layer.masksToBounds = true;


    self.lineChart.backgroundColor = NSUIColor.clear
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

