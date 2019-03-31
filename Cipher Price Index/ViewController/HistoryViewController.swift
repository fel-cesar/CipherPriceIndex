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
    // Set automatic dimensions for row height
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = UITableView.automaticDimension
    let desiredColor = UIColor.clear;
    self.tableView.backgroundColor = desiredColor;
    self.tableView.backgroundView?.backgroundColor = desiredColor;

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

  //MARK: UIDatePicker

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

  //MARK: UITableView DataSource

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return historyEntries.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "historyEntryCell", for: indexPath) as! CustomTableViewCell

//    let dateString = sourceString
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd-MM-yyyy"
    let displayDate = dateFormatter.string(from: self.historyEntries[indexPath.row].date)
    cell.dateLabel.text = "\(displayDate)"

    cell.valueLabel.text = "\(selectedCurrency) \(historyEntries[indexPath.row].rate)"

    return cell
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50.0 //UITableView.automaticDimension
  }
  // MARK: Helper functions
  private func setupView() {
    // Creating Gradient Background
    let gradient = CAGradientLayer(start: .topLeft, end: .bottomRight, colors: [
      UIColor.init(red: 54.0/255.0, green: 55.0/255.0, blue: 87.0/255.0, alpha: 1.0).cgColor,
      UIColor.init(red: 38.0/255.0, green: 38.0/255.0, blue: 67.0/255.0, alpha: 1.0).cgColor,
      UIColor.init(red: 21.0/255.0, green: 22.0/255.0, blue: 46.0/255.0, alpha: 1.0).cgColor],
                                   type: .axial)
    gradient.frame = view.bounds
    view.layer.insertSublayer(gradient, at: 0)

    // Creating gradient background for main value
    let gradientSmall = CAGradientLayer(start: .topLeft, end: .bottomRight, colors: [
      UIColor.init(red: 104.0/255.0, green: 49.0/255.0, blue: 231.0/255.0, alpha: 1.0).cgColor,
      UIColor.init(red: 119.0/255.0, green: 80.0/255.0, blue: 231.0/255.0, alpha: 1.0).cgColor,
      UIColor.init(red: 154.0/255.0, green: 119.0/255.0, blue: 232.0/255.0, alpha: 1.0).cgColor],
                                        type: .axial)
    gradientSmall.frame = self.datePickerBackgroundView.bounds
    self.datePickerBackgroundView.layer.insertSublayer(gradientSmall, at: 0)
    self.datePickerBackgroundView.layer.cornerRadius = 30;
    self.datePickerBackgroundView.layer.masksToBounds = true;

  }

  private func dateFromString(sourceString:String, fromFormat:String = "dd/MM/yyyy") -> Date {

    let dateString = sourceString
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = fromFormat

    return dateFormatter.date(from: dateString)! // Date object

//    dateFormatter.dateFormat = toFormat
//    return dateFormatter.string(from: dateObj!)

  }

}
