//
//  UserResourceService.swift
//  PADDTDR
//
//  Created by Holló Balázs on 2022. 12. 08..
//

import Foundation
import Combine

protocol UserResourceServiceProtocol: AnyObject {
    func getCurrentUserDetails() -> AnyPublisher<CurrentUserDetailsResponse, APIErrorHandler>
    func updateCurrentUser(user: UserUpdateRequest) -> AnyPublisher<CurrentUserDetailsResponse, APIErrorHandler>
    func registerBasicInfo(user: UserCreateRequest) -> AnyPublisher<CurrentUserDetailsResponse, APIErrorHandler>
    func onboardingUserLink() -> AnyPublisher<UrlWrapper, APIErrorHandler>
    func getUserDetails(id: Int) -> AnyPublisher<UserDetailsResponse, APIErrorHandler>
}

final class UserResourceService: UserResourceServiceProtocol {
    private let networkManager: NetworkManager

    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func getCurrentUserDetails() -> AnyPublisher<CurrentUserDetailsResponse, APIErrorHandler> {
        let request = UserResourceProvider.getCurrentUserDetails.makeRequest
        return networkManager.performAuthenticatedRequest(request, decodingType: CurrentUserDetailsResponse.self)
    }
    
    func updateCurrentUser(user: UserUpdateRequest) -> AnyPublisher<CurrentUserDetailsResponse, APIErrorHandler> {
        let request = UserResourceProvider.updateCurrentUser(user).makeRequest
        return networkManager.performAuthenticatedRequest(request, decodingType: CurrentUserDetailsResponse.self)
    }
    
    func registerBasicInfo(user: UserCreateRequest) -> AnyPublisher<CurrentUserDetailsResponse, APIErrorHandler> {
        let request = UserResourceProvider.registerBasicInfo(user).makeRequest
        return networkManager.performAuthenticatedRequest(request, decodingType: CurrentUserDetailsResponse.self)
    }
    
    func onboardingUserLink() -> AnyPublisher<UrlWrapper, APIErrorHandler> {
        let request = UserResourceProvider.onboardingUserLink.makeRequest
        return networkManager.performAuthenticatedRequest(request, decodingType: UrlWrapper.self)
    }
    
    func getUserDetails(id: Int) -> AnyPublisher<UserDetailsResponse, APIErrorHandler> {
        let request = UserResourceProvider.getUserDetails(id: id).makeRequest
        return networkManager.performAuthenticatedRequest(request, decodingType: UserDetailsResponse.self)
    }
}
