//
//  WhoofRequests.swift
//  Whoof
//
//  Created by Suchith Nayaka on 13/06/22.
//

import Foundation
import Combine
import UIKit
import SwiftUI

public typealias Headers = [String: String]

// if you wish you can have multiple services like this in a project
enum WhoofEndpoints {
    
    case feedFood
    case feedWater
    
    //specify the type of HTTP request
    var httpMethod: HTTPMethod {
        switch self {
        case .feedFood,.feedWater:
            return .GET
        }
    }
    
    // compose the NetworkRequest
    func createRequest(token: String = "", environment: NetworkEnvironment) -> NetworkRequest {
        var headers: Headers = [:]
        headers["Content-Type"] = "application/json"
        //        headers["Authorization"] = "Bearer \(token)"
        return NetworkRequest(url: getURL(from: environment), headers: headers, reqBody: requestBody, httpMethod: httpMethod)
    }
    
    // encodable request body for POST
    var requestBody: Encodable? {
        switch self {
        case .feedFood:
            return nil
        case .feedWater:
            return nil
        }
    }
    // compose urls for each request
    func getURL(from environment: NetworkEnvironment) -> String {
        let baseUrl = environment.whoofServiceBaseURL
        switch self {
        case .feedFood:
            return "\(baseUrl)/feedFood"
        case .feedWater:
            return "\(baseUrl)/feedWater"
            
        }
    }
}

public enum NetworkEnvironment: String, CaseIterable {
    case development
    case staging
    case production
}

extension NetworkEnvironment {
    var whoofServiceBaseURL: String {
        switch self {
        case .development:
            return "https://accounts.whoof.net/api"
        case .staging:
            return "https://accounts.whoof.net/api"
        case .production:
            return "https://accounts.whoof.net/api"
        }
    }
}


protocol WhoofServiceable {
    
    func feedFood() -> AnyPublisher<FeedNetworkResponseModel, NetworkRequestError>
    func feedWater() -> AnyPublisher<FeedNetworkResponseModel, NetworkRequestError>
    
}

class WhoofService: WhoofServiceable {
    
    func feedFood() -> AnyPublisher<FeedNetworkResponseModel, NetworkRequestError> {
        let endpoint = WhoofEndpoints.feedFood
        let request = endpoint.createRequest(environment: self.environment)
        return self.networkRequest.request(request)
    }
    
    func feedWater() -> AnyPublisher<FeedNetworkResponseModel, NetworkRequestError> {
        let endpoint = WhoofEndpoints.feedWater
        let request = endpoint.createRequest(environment: self.environment)
        return self.networkRequest.request(request)
    }
    
    
    private var networkRequest: Requestable
    private var environment: NetworkEnvironment = .production
    
    convenience init() {
        self.init(networkRequest: NativeRequestable(), environment: .production)
    }
    // inject this for testability
    init(networkRequest: Requestable, environment: NetworkEnvironment) {
        self.networkRequest = networkRequest
        self.environment = environment
    }
}

