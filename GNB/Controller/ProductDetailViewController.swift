//
//  ProductDetailViewController.swift
//  GNB
//
//  Created by Florin Uscatu on 5/18/18.
//  Copyright © 2018 Florin Uscatu. All rights reserved.
//

import UIKit

class ProductDetailViewController: UITableViewController, ConversionDelegate {

    // The reuse identifier for the cells
    let transactionCellID = "transactionCell"
    
    // The URL for the API call
    let conversionURL = "http://gnb.dev.airtouchmedia.com/rates.json"
    
    // Array that holds the conversion rates fetched through the API
    var conversionRates: [ConversionRate] = []
    
    // Product variable that holds the data passed through the segue from the previos view controller
    var product: Product?
    
    // Variable that holds the total of the transaction amounts
    var total: Double = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitle()
        requestData()
    }
    
    func setTitle() {
        // Sets the title of the view controller
        if let sku = product?.sku {
            self.title = sku + " Transactions"
        }
    }
    
    // Request the data from the API through the delegate
    func requestData() {
        DispatchQueue.global(qos: .background).async {
            RequestHandler.Instance.conversionRateControllerDelegate = self
            RequestHandler.Instance.fetchConversionRates(stringUrl: self.conversionURL)
        }
        
    }
    
    // Delegate method
    func fetchedConversionRates(_ conversionRates: [ConversionRate]) {
        self.conversionRates = conversionRates
        
        DispatchQueue.global(qos: .background).async {
            self.calculateTotal()
        }
        
    }
    
    // This function calculates the total and reloads the table view
    func calculateTotal() {
        
        guard let transactions = product?.transactions else {return}
        
        for transaction in transactions {
            
            guard let amount = Double(transaction.amount) else {return}
            
            if transaction.currency == "EUR" {
                total += amount
            } else {
                total += convertAmountToEur(amount: amount, from: transaction.currency)
            }
        }
        
        // Rounding the total half to even with two decimal places
        total = total.bankerRounding()
        
        // Calling the reload of the table view on the main queue
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
    // This function converts the amount requested into euros
    func convertAmountToEur(amount: Double, from: String) -> Double {
        
        let rate = findExchangeRate(to: "EUR", from: from)
        
        // Rounding the result half to even with two decimal places
        let result = amount * rate
        let roundedResult = result.bankerRounding()
        
        return roundedResult
    }
    
    // This function is in charge of finding the exchange rate needed for any pair
    func findExchangeRate(to: String, from: String) -> Double {
        
        // The function first checks if the exchange rate already exists in the Array
        
        if let index = conversionRates.index(where: {$0.from == from && $0.to == to}) {
            
            guard let rate = Double(conversionRates[index].rate) else {return 0.0}
            
            return rate
            
        } else {
            
            // If it does not exist in the Array it goes through all of the other possible pairs to try and create an exchange rate
            
            let matchingOrigins = conversionRates.filter({$0.from == from})
            let matchingDestinations = conversionRates.filter({$0.to == to})
            
            for conversionRateOrigin in matchingOrigins {
                for conversionRateDest in matchingDestinations {
                    
                    // After going through both of the created arrays, if it finds the right computed rate it returns it
                    
                    guard let originRate = Double(conversionRateOrigin.rate) else {return 0.0}
                    guard let destRate = Double(conversionRateDest.rate) else {return 0.0}
                    
                    if conversionRateOrigin.to == conversionRateDest.from {
                        
                        let resultRate = originRate * destRate
                        
                        // Added this line which adds the succesfully found pair to the array for easier retrieval on the next call of the function
                        conversionRates.append(ConversionRate(from: from, to: to, rate: String(resultRate)))
                        
                        return resultRate
                    } else {
                        
                        // In case it cannot find the right rate it calls the function again while multiplying with the already found rates
                        
                        return findExchangeRate(to: conversionRateDest.from, from: conversionRateOrigin.to) * originRate * destRate
                    }
                }
            }
            
        }
        return 0.0
    }
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            guard let numberOfTransactions = product?.transactions.count else {return 0}
            return numberOfTransactions
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: transactionCellID, for: indexPath) as! TransactionTableViewCell
        
        if indexPath.section == 0 {
            if let amount = product?.transactions[indexPath.row].amount, let currency = product?.transactions[indexPath.row].currency {
                cell.transactionLabel.text = amount + " " + currency
            }
        } else {
            cell.transactionLabel.text = "Total " + "\(total) EUR"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }


}
