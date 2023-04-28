//
//  DashboardViewModel.swift
//  NetworkLayerRefact
//
//

import Foundation
import Combine

final class DashboardViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    private var networkManager: NetworkManager
    private let languageCountryService: LanguageCountryServiceProtocol
    
    @Published var languages: [LanguageDTO] = []
    @Published var countries: [CountryDTO] = []

    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
        self.languageCountryService = LanguageCountryService(networkManager: networkManager)
    }
    
    func loadingLanguages() {
        languageCountryService.getLanguageAndCountryData()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                case .finished:
                    print("finished api call")
                }
            } receiveValue: { [weak self] languages, countries in
                self?.languages = languages
                self?.countries = countries
            }
            .store(in: &cancellables)
    }
}
