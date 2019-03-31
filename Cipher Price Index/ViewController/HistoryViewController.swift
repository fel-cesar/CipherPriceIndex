//
//  HistoryViewController.swift
//  Cipher Price Index
//
//  Created by Felipe César Silveira de Assis on 31/03/19.
//  Copyright © 2019 Cipher Studio. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

  @IBOutlet weak var datePickerBackgroundView: UIView!
  @IBOutlet weak var startDateTextField: UITextField!
  @IBOutlet weak var endDateTextField: UITextField!
  @IBOutlet weak var tableView: UITableView!

  let datePickerStart = UIDatePicker()
  let datePickerEnd = UIDatePicker()

  var historyEntries: [BitcoinPrice] = []
  private let disposeBag = DisposeBag()
  private var selectedCurrency = ""
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.dataSource = self
    tableView.delegate = self
    tableView.keyboardDismissMode = .onDrag

    setupView()
    initDatePicker()

    UserDefaults.standard.rx
      .observe(String.self, "SelectedCurrency")
      .debounce(0.1, scheduler: MainScheduler.asyncInstance).subscribe(onNext: { (value) in
        if let value = value {
          self.selectedCurrency = value

          CoinDeskAPI.getHistorical(currency: value).observeOn(MainScheduler.instance)
            .subscribe(onNext: { bitcoinPrices in
              self.historyEntries.removeAll()
              self.historyEntries.append(contentsOf: bitcoinPrices)
              self.tableView.reloadData()
            }, onError: { (error) in
              print(error)
            })
            .disposed(by: self.disposeBag)
        }
      }).disposed(by: self.disposeBag)

    let startDateObserver = startDateTextField.rx.text.orEmpty.asObservable()
    let endDateObserver = endDateTextField.rx.text.orEmpty.asObservable()

    Observable.combineLatest(startDateObserver, endDateObserver) { textStart, textEnd in
      if textStart == "" || textEnd == "" {
        return
      }


      let startDate = self.dateFromString(sourceString: textStart)
      let endDate = self.dateFromString(sourceString: textEnd)

      if let currency = UserDefaults.standard.string(forKey: "SelectedCurrency"){
        CoinDeskAPI.getHistorical(currency: currency, startDate: startDate, endDate: endDate).observeOn(MainScheduler.instance)
          .subscribe(onNext: { bitcoinPrices in
            self.historyEntries.removeAll()
            self.historyEntries.append(contentsOf: bitcoinPrices)
            self.tableView.reloadData()

          }, onError: { (error) in
            print(error)
          })
          .disposed(by: self.disposeBag)
      }
      print("\(textStart) \(textEnd)")

      }.observeOn(MainScheduler.instance)
      .subscribe()
      .disposed(by: disposeBag)

    }

  // MARK: UIDatePicker

  func initDatePicker() {
    //Formate Date
    datePickerStart.datePickerMode = .date
    datePickerEnd.datePickerMode = .date

    //ToolBar
    let toolbarStart = UIToolbar()
    toolbarStart.sizeToFit()

    // Aux Buttons - start
    let doneButtonStart = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(doneDatePicker))
    let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
    let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(cancelDatePicker))
    toolbarStart.setItems([doneButtonStart,spaceButton,cancelButton], animated: true)
    startDateTextField.inputAccessoryView = toolbarStart
    startDateTextField.inputView = datePickerStart

    // Aux Buttons - end
    let toolbarEnd = UIToolbar()
    toolbarEnd.sizeToFit()
    let doneButtonEnd = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(doneDatePickerEnd))
    toolbarEnd.setItems([doneButtonEnd, spaceButton, cancelButton], animated: true)
    endDateTextField.inputAccessoryView = toolbarEnd
    endDateTextField.inputView = datePickerEnd

  }

  @objc func doneDatePicker(){
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM/yyyy"
    startDateTextField.text = formatter.string(from: datePickerStart.date)
    self.view.endEditing(true)
  }

  @objc func doneDatePickerEnd(){
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM/yyyy"
    endDateTextField.text = formatter.string(from: datePickerEnd.date)
    self.view.endEditing(true)
  }

  @objc func cancelDatePicker(){
    self.view.endEditing(true)
  }

  // MARK: UITableView DataSource

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return historyEntries.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "historyEntryCell", for: indexPath) as! CustomTableViewCell

    let bitcoinPriceView = BitcoinPriceView.init(bitcoinPrice: self.historyEntries[indexPath.row])
    cell.dateLabel.text = "\(bitcoinPriceView.dateText)"
    cell.valueLabel.text = "\(selectedCurrency) \(bitcoinPriceView.valueText)"

    return cell
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50.0
  }

  // MARK: Helper functions

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  private func setupView() {

    // Disabling tableView backgrounds
    let desiredColor = UIColor.clear;
    self.tableView.backgroundColor = desiredColor;
    self.tableView.backgroundView?.backgroundColor = desiredColor;

    // Creating Gradient Background
    let gradient = GradientPreset.darkBackground.gradient
    gradient.frame = view.bounds
    view.layer.insertSublayer(gradient, at: 0)

    // Creating gradient background for main value
    let gradientSmall = GradientPreset.lavander.gradient
    gradientSmall.frame = self.datePickerBackgroundView.bounds
    self.datePickerBackgroundView.layer.insertSublayer(gradientSmall, at: 0)
    self.datePickerBackgroundView.layer.cornerRadius = 30;
    self.datePickerBackgroundView.layer.masksToBounds = true;
  }

  private func dateFromString(sourceString:String, fromFormat:String = "dd/MM/yyyy") -> Date {
    let dateString = sourceString
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = fromFormat
    return dateFormatter.date(from: dateString)!
  }
}
