//
//  ConversionRate.swift
//  GNB
//
//  Created by Florin Uscatu on 5/18/18.
//  Copyright © 2018 Florin Uscatu. All rights reserved.
//

import Foundation


struct ConversionRate: Decodable {
    var from: String
    var to: String
    var rate: String
}
