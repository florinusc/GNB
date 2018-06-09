//
//  ViewController.swift
//  GNB
//
//  Created by Florin Uscatu on 5/18/18.
//  Copyright © 2018 Florin Uscatu. All rights reserved.
//

import UIKit

class ProductsViewController: UITableViewController, TransactionDelegate {

    // Dictionary that contains the sorted products
    var productArray: [Product] = []
    
    // The reuse identifier for the cells
    let cellID = "productCell"
    
    // URL for requesting the list of transactions
    let transactionsURL = "http://gnb.dev.airtouchmedia.com/transactions.json"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestData()
    }
    
    // Request the data from the API through the delegate
    func requestData() {
        DispatchQueue.global(qos: .background).async {
            RequestHandler.Instance.transactionControllerDelegate = self
            RequestHandler.Instance.fetchTransactions(stringUrl: self.transactionsURL)
        }
        
    }
    
    // Delegate method
    func fetchedTransactions(_ transactions: [Transaction]) {
        // Populate the local array
        DispatchQueue.global(qos: .background).async {
            self.sortTransactions(transactions: transactions)
        }
    }
    
    // Goes through each of the entries in the array and sorts them into a dictionary where the keys are the skus and each sku gets as value an array of transactions
    func sortTransactions(transactions: [Transaction]) {
        for transaction in transactions {
            
            if productArray.contains(where: {$0.sku == transaction.sku}) {
                
                if let index = productArray.index(where: {$0.sku == transaction.sku}) {
                    productArray[index].transactions.append(transaction)
                }
                
            } else {
                productArray.append(Product(sku: transaction.sku, transactions: [transaction]))
            }
        }
        
        // Calling the reload of the tableView on the main queue
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }

    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! ProductTableViewCell
        
        cell.skuLabel.text = "(change 1) SKU: " + productArray[indexPath.row].sku
        
        cell.transactionsNumberLabel.text = "(\(productArray[indexPath.row].transactions.count) transactions)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    // Passes the product details from this viewcontroller to the next one through segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "goToProduct" {
            
            guard let productDetailViewController = segue.destination as? ProductDetailViewController else { fatalError("Unexpected destination") }
            guard let selectedCell = sender as? ProductTableViewCell else { fatalError("Unexpected sender") }
            guard let indexPath = tableView.indexPath(for: selectedCell) else { fatalError("Cannot find cell") }
            
            let selectedProduct = productArray[indexPath.row]
            productDetailViewController.product = selectedProduct
            
        }
    }
    
}


