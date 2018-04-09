//
//  MainAPIClient.swift
//  VenezuelaDreams
//
//  Created by Andres Prato on 4/5/18.
//  Copyright © 2018 Andres Prato. All rights reserved.
//

import Foundation
import Stripe
import Firebase
import Alamofire

class MainAPIClient: NSObject, STPEphemeralKeyProvider {
    
    static let shared = MainAPIClient()
    
    var baseURLString = "https://us-central1-vzladreams.cloudfunctions.net"
    var stripe_id = String()
    
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock)
    {
        let stripe_id = UserDefaults.standard.string(forKey: "stripe_id")
        print(stripe_id!)
        let baseURL = URL(string: baseURLString)
        
        let url = baseURL?.appendingPathComponent("StripeEphemeralKeys")
        Alamofire.request(url!, method: .post, parameters: [
            "api_version": apiVersion, "customerId": stripe_id!
            ])
            .validate(statusCode: 200..<300)
            .responseJSON { responseJSON in
                switch responseJSON.result {
                case .success(let json):
                    print("WORKED!")
                    completion(json as? [String: AnyObject], nil)
                case .failure(let error):
                    print("FAILURE \(error)")
                    completion(nil, error)
                }
        }
    }
}

