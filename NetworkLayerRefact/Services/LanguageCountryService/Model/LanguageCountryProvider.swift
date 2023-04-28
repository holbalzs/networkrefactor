//
//  LanguageCountryProvider.swift
//  PADDTDR
//
//  Created by Czigány Tamás on 14/07/2022.
//

import Foundation

enum LanguageCountryProvider {
    case getLanguages
    case getCountries
}

extension LanguageCountryProvider: ApiEndpoint {
    var baseURLString: String {
        return ConfigurationApp.API.apiURL
    }
    
    var apiPath: String {
        return "api"
    }
    
    var apiVersion: String {
        "v1"
    }
    
    var separatorPath: String? {
        return nil
    }
    
    var path: String {
        switch self {
        case .getLanguages:
            return "languages"
        case .getCountries:
            return "countries"
        }
    }
    
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
    
    var queryForCall: [URLQueryItem]? {
        switch self {
        default:
            return nil
        }
    }
    
    var params: [String: Any]? {
        return nil
    }
    
    var method: APIHTTPMethod {
        return .GET
    }
    
    var customDataBody: Data? {
        return nil
    }
}
