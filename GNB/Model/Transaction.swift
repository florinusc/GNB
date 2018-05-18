//
//  Transaction.swift
//  GNB
//
//  Created by Florin Uscatu on 5/18/18.
//  Copyright © 2018 Florin Uscatu. All rights reserved.
//

import Foundation


struct Transaction: Decodable {
    var sku: String
    var amount: String
    var currency: String
}
