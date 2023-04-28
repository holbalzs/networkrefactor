//
//  LanguageCountryService.swift
//  PADDTDR
//
//  Created by Czigány Tamás on 14/07/2022.
//

import Foundation
import Combine

protocol LanguageCountryServiceProtocol: AnyObject {
    func getLanguageAndCountryData() -> AnyPublisher<([LanguageDTO], [CountryDTO]), APIErrorHandler>
}

final class LanguageCountryService: LanguageCountryServiceProtocol {
    private let networkManager: NetworkManager

    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func getLanguageData() -> AnyPublisher<[LanguageDTO], APIErrorHandler> {
        let request = LanguageCountryProvider.getLanguages.makeRequest
        return networkManager.performAuthenticatedRequest(request, decodingType: [LanguageDTO].self)
    }
    
    func getCountryData() -> AnyPublisher<[CountryDTO], APIErrorHandler> {
        let request = LanguageCountryProvider.getCountries.makeRequest
        return networkManager.performAuthenticatedRequest(request, decodingType: [CountryDTO].self)
    }
    
    func getLanguageAndCountryData() -> AnyPublisher<([LanguageDTO], [CountryDTO]), APIErrorHandler> {
        return Publishers.Zip(getLanguageData(), getCountryData())
            .eraseToAnyPublisher()
    }
}
