//
//  HTTPRequestHandler.swift
//  GNB
//
//  Created by Florin Uscatu on 5/18/18.
//  Copyright © 2018 Florin Uscatu. All rights reserved.
//

import Foundation
import Alamofire


protocol TransactionDelegate {
    func fetchedTransactions(_ transactions: [Transaction])
}

protocol ConversionDelegate {
    func fetchedConversionRates(_ conversionRates: [ConversionRate])
}

class RequestHandler {
    
    private static let _instance = RequestHandler()
    
    static var Instance: RequestHandler {
        return _instance
    }
    
    var transactionControllerDelegate: TransactionDelegate?
    var conversionRateControllerDelegate: ConversionDelegate?
    
    let headers: HTTPHeaders = ["Accept": "application/json", "Content-Type":"application/json"]
    
    func fetchTransactions(stringUrl: String) {
        
        guard let url = URL(string: stringUrl) else {return}
        
        Alamofire.request(url, method: .get, parameters: [:], encoding: URLEncoding.queryString, headers: headers).responseJSON { response in
            
            if let data = response.data {
                
                do {
                    let decoder = JSONDecoder()
                    let transactions = try decoder.decode([Transaction].self, from: data)
                    
                    DispatchQueue.main.async {
                        self.transactionControllerDelegate?.fetchedTransactions(transactions)
                    }
                    
                } catch let err {
                    print("Error reading data from JSON: " + err.localizedDescription)
                }
            }
        }
    }
    
    func fetchConversionRates(stringUrl: String) {
        
        guard let url = URL(string: stringUrl) else {return}
        
        Alamofire.request(url, method: .get, parameters: [:], encoding: URLEncoding.queryString, headers: headers).responseJSON { response in
            
            if let data = response.data {
                
                do {
                    let decoder = JSONDecoder()
                    let conversionRates = try decoder.decode([ConversionRate].self, from: data)
                    
                    DispatchQueue.main.async {
                        self.conversionRateControllerDelegate?.fetchedConversionRates(conversionRates)
                    }
                    
                } catch let err {
                    print("Error reading data from JSON: " + err.localizedDescription)
                }
            }
        }
    }
    
}
