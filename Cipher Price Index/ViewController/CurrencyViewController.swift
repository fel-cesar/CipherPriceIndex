//
//  CurrencyViewController.swift
//  Cipher Price Index
//
//  Created by Felipe César Silveira de Assis on 31/03/19.
//  Copyright © 2019 Cipher Studio. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CurrencyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {


  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var tableView: UITableView!

  let disposeBag = DisposeBag()

  var currencies: [Currency] = []
  var currenciesDisplay: [Currency] = []

  override func viewDidLoad() {

    super.viewDidLoad()
    tableView.dataSource = self
    tableView.delegate = self
    tableView.keyboardDismissMode = .onDrag
    setupView()
    let apiErrorClosure: (Error) -> Void = { error in
      switch error {
      case ApiError.forbidden:
        print("Forbidden error")
      case ApiError.notFound:
        print("Not found error")
      default:
        print("Unknown error:", error)
      }
    }

    CoinDeskAPI.getSupportedCurrencies().observeOn(MainScheduler.instance)
      .subscribe(onNext: { currency in
        print(currency.country)
        self.currencies.append(currency)
      }, onError: apiErrorClosure, onCompleted: {
        self.currenciesDisplay = self.currencies
        self.tableView.reloadData()
      })
      .disposed(by: disposeBag)


    searchBar.rx.text.orEmpty
      .subscribe(onNext: { [unowned self] query in
        self.currenciesDisplay = self.currencies.filter({ (currency) -> Bool in
          return (currency.code.hasPrefix(query) || currency.country.hasPrefix(query))
        })
        self.tableView.reloadData()
      })
      .disposed(by:disposeBag)
    }
    
  // MARK: UITableViewDataSource

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return currenciesDisplay.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let cell = tableView.dequeueReusableCell(withIdentifier: "cityPrototypeCell", for: indexPath) as! CurrencyTableViewCell
    cell.codeLabel.text = "\(self.currenciesDisplay[indexPath.row].code)"
    cell.countryLabel.text = "\(self.currenciesDisplay[indexPath.row].country)"

    return cell
  }

  // MARK: UITableViewDelegate

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    UserDefaults.standard.set(self.currenciesDisplay[indexPath.row].code, forKey: "SelectedCurrency")
    self.dismiss(animated: true, completion: nil)
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60.0
  }

  // MARK: Helper methods

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  private func setupView() {
    let desiredColor = UIColor.clear;
    self.tableView.backgroundColor = desiredColor;
    self.tableView.backgroundView?.backgroundColor = desiredColor;

    // Creating Gradient Background
    let gradient = GradientPreset.darkBackground.gradient
    gradient.frame = view.bounds
    view.layer.insertSublayer(gradient, at: 0)

    navigationController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissViewController))

  }

  @objc func dismissViewController(){
    self.dismiss(animated: true)
  }
}
