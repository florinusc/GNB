//
//  Double+BankerRounding.swift
//  GNB
//
//  Created by Florin Uscatu on 5/18/18.
//  Copyright © 2018 Florin Uscatu. All rights reserved.
//

import Foundation


extension Double {
    func bankerRounding() -> Double {
        return Double(lrint(self * 100)) / 100
    }
}
