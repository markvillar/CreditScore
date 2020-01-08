//
//  Service.swift
//  CreditScore
//
//  Created by Mark on 31/10/2019.
//  Copyright © 2019 CreditScore. All rights reserved.
//

import Foundation

class Service: NSObject {
    
    fileprivate static let session = URLSession(configuration: URLSessionConfiguration.default)
    
    static let shared = Service()
    
    
    /// Closure that retrieves account details from specifed URL
    /// - Parameter url: String URL to the endpoint
    /// - Parameter completion: Returns a DashboardViewModel or an Error.
    func fetchAccount(url: String, completion: @escaping (DashBoardViewModel?, Error?) -> ()) {
        
        guard let jsonURL = URL(string: url) else { return }
        
        Service.session.dataTask(with: jsonURL) { (data, response, err) in
            
            if let err = err {
                completion(nil, err)
                print("Failed to fetch account:", err)
                return
            }
            
            // Check the response
            guard let data = data else { return }
            
            do {
                let account = try JSONDecoder().decode(Account.self, from: data)
                let dashBoardViewModel = DashBoardViewModel(account: account)
                
                DispatchQueue.main.async {
                    completion(dashBoardViewModel, nil)
                }
                
            } catch let jsonError {
                print("Failed to decode:", jsonError)
            }
        }.resume()
    }
    
}
