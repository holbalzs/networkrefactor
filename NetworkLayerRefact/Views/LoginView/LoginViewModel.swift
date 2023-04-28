//
//  LoginViewModel.swift
//  PADDTDR
//
//  Created by Balázs Holló on 2022. 07. 07..
//

import SwiftUI

final class LoginViewModel: ObservableObject {
    
    private var networkManager: NetworkManager
    @Published var isSuccessLogin: Bool = false

    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func startLoginFlow() -> URL {
        let baseURLString = ConfigurationApp.API.keyCloak
        let path = "/auth/realms/tuudr/protocol/openid-connect/auth"
        let responseType = "code"
        let clientId = "tuudr-frontend"
        let redirectURI = "tuudr://home"

        var components = URLComponents(string: baseURLString)
        components?.path = path
        components?.queryItems = [URLQueryItem]()
        components?.queryItems?.append(URLQueryItem(name: "response_type", value: responseType))
        components?.queryItems?.append(URLQueryItem(name: "client_id", value: clientId))
        components?.queryItems?.append(URLQueryItem(name: "redirect_uri", value: redirectURI))

        guard let url = components?.url else {
            return URL(string: "https://tuudr.com")!
        }
        return url
    }
    
    private func startExchange(from request: URLRequest) {
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if error == nil, let data = data {
                    let jwt = try? JSONDecoder().decode(AuthenticationJWTDTO.self, from: data)
                    self.networkManager.authenticator.setToken(jwt)
                    if jwt?.isValid() == true {
                        self.isSuccessLogin = true
                    } else {
                        self.isSuccessLogin = false
                    }
                }
            }
        }.resume()
    }

    func exchangeCodeForToken(_ url: URL) {
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let sessionState = urlComponents?.queryItems?.first(where: { $0.name == "session_state" })?.value
        let code = urlComponents?.queryItems?.first(where: { $0.name == "code" })?.value
        guard
        let code = code,
        let state = sessionState,
        let exchangeUrl = URL(
            string: "\(ConfigurationApp.API.keyCloak)/auth/realms/tuudr/protocol/openid-connect/token"
        ) else {
            return
        }
        let request = generateRequest(
            url: exchangeUrl,
            sessionState: state,
            code: code,
            redirect: "tuudr://home"
        )
        startExchange(from: request)
    }

    private func generateRequest(url: URL, sessionState: String, code: String, redirect: String) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = APIHTTPMethod.POST.rawValue
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [URLQueryItem]()
        requestBodyComponents.queryItems?.append(URLQueryItem(name: "client_id", value: "tuudr-frontend"))
        requestBodyComponents.queryItems?.append(URLQueryItem(name: "grant_type", value: "authorization_code"))
        requestBodyComponents.queryItems?.append(URLQueryItem(name: "session_state", value: sessionState))
        requestBodyComponents.queryItems?.append(URLQueryItem(name: "code", value: code))
        requestBodyComponents.queryItems?.append(URLQueryItem(name: "redirect_uri", value: redirect))
        urlRequest.httpBody = requestBodyComponents.query?.data(using: .utf8)
        return urlRequest
    }
    
    func exchangeFromAppSignIn(params: MinimalJWTpost) {
        guard let url = URL(string: "\(ConfigurationApp.API.apiURL)/api/v1/auth/apple/exchange-id-token") else { return }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("*/*", forHTTPHeaderField: "Accept")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let paramData = params.asDictionary() {
            let jsonData = try? JSONSerialization.data(withJSONObject: paramData)
            urlRequest.httpBody = jsonData
        }
        
        startExchange(from: urlRequest)
    }
}

struct MinimalJWTpost: Encodable {
    let idToken: String
    let userFirstName: String?
    let userLastName: String?
}
