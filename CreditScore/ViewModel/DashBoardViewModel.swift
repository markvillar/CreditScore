//
//  DashBoardViewModel.swift
//  CreditScore
//
//  Created by Mark on 31/10/2019.
//  Copyright © 2019 CreditScore. All rights reserved.
//

import Foundation

struct DashBoardViewModel {
    
    let score: Double
    let maximumScore: Double
    let minimumScore: Double
    var progressBarValue: Double {
        score / maximumScore
    }
    
    init(account: Account) {
        self.score = account.creditReportInfo.score
        self.maximumScore = account.creditReportInfo.maxScoreValue
        self.minimumScore = account.creditReportInfo.minScoreValue
    }
    
}
