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
    let cell = tableView.dequeueReusableCell(withIdentifier: "cityPrototypeCell", for: indexPath)
    cell.textLabel?.text = "\(self.currenciesDisplay[indexPath.row].country)"
    return cell
  }

  // MARK: UITableViewDelegate

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    UserDefaults.standard.set(self.currenciesDisplay[indexPath.row].code, forKey: "SelectedCurrency")
    self.dismiss(animated: true, completion: nil)
  }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
