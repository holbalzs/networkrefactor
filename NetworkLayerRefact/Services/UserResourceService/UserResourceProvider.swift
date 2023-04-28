//
//  UserResourceProvider.swift
//  PADDTDR
//
//  Created by Holló Balázs on 2022. 12. 08..
//

import Foundation

// user-resource

enum UserResourceProvider {
    case getCurrentUserDetails
    case updateCurrentUser(UserUpdateRequest)
    case registerBasicInfo(UserCreateRequest)
    case deleteCurrentUser
    case onboardingUserLink
    case verification
    case hasPaymentMethod
    case getUserDetails(id: Int)
}

extension UserResourceProvider: ApiEndpoint {
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
        switch self {
        default:
            return "users"
        }
    }
    
    var path: String {
        switch self {
        case .getCurrentUserDetails, .updateCurrentUser, .registerBasicInfo, .deleteCurrentUser:
            return "current-user"
        case .hasPaymentMethod:
            return "current-user/has-payment-method"
        case .onboardingUserLink:
            return "current-user/onboarding-link"
        case .verification:
            return "current-user/verification"
        case .getUserDetails(let id):
            return "\(id)"
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .updateCurrentUser, .registerBasicInfo:
            return ["Content-Type": "application/json"]
        default:
            return nil
        }
    }
    
    var queryForCall: [URLQueryItem]? {
        switch self {
        default:
            return nil
        }
    }
    
    var params: [String: Any]? {
        switch self {
        case .updateCurrentUser(let request):
            return request.asDictionary()
        case .registerBasicInfo(let request):
            return request.asDictionary()
        default:
            return nil
        }
    }
    
    var method: APIHTTPMethod {
        switch self {
        case .getCurrentUserDetails, .hasPaymentMethod, .verification, .getUserDetails:
            return .GET
        case .updateCurrentUser:
            return .PUT
        case .registerBasicInfo, .onboardingUserLink:
            return .POST
        case .deleteCurrentUser:
            return .DELETE
        }
    }
    
    var customDataBody: Data? {
        return nil
    }
}
