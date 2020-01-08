//
//  CreditReport.swift
//  CreditScore
//
//  Created by Mark on 31/10/2019.
//  Copyright © 2019 CreditScore. All rights reserved.
//

import Foundation

/// Used Double as data type assuming scores may include decimal points
struct CreditReport: Decodable {
    let score: Double
    let maxScoreValue: Double
    let minScoreValue: Double
}
