//
//  Authenticator.swift
//  NetworkLayerRefact
//
//

import Foundation
import Combine

enum TokenState: String {
    case none, validAccess, validRefresh, expired
    case loggedIn // loggedIn state
    case profileFinished // if profile need to fill more data
}

class Authenticator: ObservableObject {
    private let tokenKeyUserDefaults = "TOKEN_DATA"
    private let session: NetworkSession
    private var currentToken: AuthenticationJWTDTO? {
        if let tokenData = UserDefaults.standard.value(forKey: tokenKeyUserDefaults) as? Data {
            return try? JSONDecoder().decode(AuthenticationJWTDTO.self, from: tokenData)
        } else {
            return nil
        }
    }
    private let queue = DispatchQueue(label: "Autenticator.\(UUID().uuidString)")

    // this publisher is shared amongst all calls that request a token refresh
    private var refreshPublisher: AnyPublisher<AuthenticationJWTDTO, APIErrorHandler>?
    
    // Token change notify the services
    private var customChangedObservers = [() -> Void]()
    func onChangeCustom(_ observer: @escaping () -> Void) {
        customChangedObservers.append(observer)
    }
    private func notifyCustomChanges() {
        customChangedObservers.forEach { $0() }
    }
    // Token change notify the services

    var reLogin: (() -> Void)?
    
    init(session: NetworkSession = URLSession.shared) {
        self.session = session
    }

    func setToken(_ token: AuthenticationJWTDTO?) {
        if let dataToken = try? JSONEncoder().encode(token) {
            UserDefaults.standard.set(dataToken, forKey: tokenKeyUserDefaults)
        }
    }

    func removeToken() {
        UserDefaults.standard.removeObject(forKey: tokenKeyUserDefaults)
    }

    // App login start
    func getTokenState() -> TokenState {
        guard let currentToken = currentToken else {
            return .none
        }
        if currentToken.isValid() {
            return .validAccess
        } else if currentToken.refreshIsValid() {
            return .validRefresh
        } else {
            return .expired
        }
    }
    
    func getNameFromToken() -> String? {
        guard let currentToken = currentToken else {
            return nil
        }
        return currentToken.getNameFromToken()
    }
    
    // acces token for socket
    func getAccessToken() -> String? {
        return currentToken?.accessToken
    }

    func validToken(forceRefresh: Bool = false) -> AnyPublisher<AuthenticationJWTDTO, APIErrorHandler> {
        return queue.sync { [weak self] in
            // scenario 1: we're already loading a new token
            if let publisher = self?.refreshPublisher {
                return publisher
            }

            // scenario 2: we don't have a token at all, the user should probably log in
            guard let token = self?.currentToken else {
                return Fail(error: APIErrorHandler.requestFailed)// AuthenticationError.loginRequired)
                    .eraseToAnyPublisher()
            }

            // scenario 3: we already have a valid token and don't want to force a refresh
            if token.isValid(), !forceRefresh {
                return Just(token)
                    .setFailureType(to: APIErrorHandler.self)
                    .eraseToAnyPublisher()
            }

            // scenario 4: we need a new token
            let endpoint = URL(string: "\(ConfigurationApp.API.keyCloak)/auth/realms/tuudr/protocol/openid-connect/token")!

            let request = generateRefreshRequest(endpoint, token)

            // let publisher = session.publisher(for: endpoint, token: nil)
            let publisher = session.publisher(request, decodingType: AuthenticationJWTDTO.self, token: nil)
                .share()
            // .decode(type: AuthenticationJWTDTO.self, decoder: JSONDecoder())
                .handleEvents(receiveOutput: { token in
                    self?.setToken(token)
                    if let dataToken = try? JSONEncoder().encode(token) {
                        UserDefaults.standard.set(dataToken, forKey: self?.tokenKeyUserDefaults ?? "TOKEN_DATA")
                        self?.notifyCustomChanges()
                    }
                }, receiveCompletion: { completition in
                    self?.queue.sync {
                        switch completition {
                        case .finished:
                            print("finished")
                        case .failure(let err):
                            print(err.localizedDescription)
                            self?.removeToken()
                            self?.reLogin?()
                        }
                        
                        self?.refreshPublisher = nil
                    }
                })
                .eraseToAnyPublisher()

            self?.refreshPublisher = publisher
            return publisher
        }
    }

    private func generateRefreshRequest(_ endpoint: URL, _ token: AuthenticationJWTDTO) -> URLRequest {
        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = APIHTTPMethod.POST.rawValue
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [URLQueryItem]()
        requestBodyComponents.queryItems?.append(URLQueryItem(name: "client_id", value: "tuudr-frontend"))

        requestBodyComponents.queryItems?.append(URLQueryItem(name: "grant_type", value: "refresh_token"))
        requestBodyComponents.queryItems?.append(URLQueryItem(name: "refresh_token", value: token.refreshToken))
        urlRequest.httpBody = requestBodyComponents.query?.data(using: .utf8)
        return urlRequest
    }

    private func refreshTokenForAppStart(_ token: AuthenticationJWTDTO) {
        let endpoint = URL(string: "\(ConfigurationApp.API.keyCloak)/auth/realms/tuudr/protocol/openid-connect/token")!
        let request = generateRefreshRequest(endpoint, token)
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if
                    error == nil,
                    let data = data,
                    let tokenData = try? JSONDecoder().decode(AuthenticationJWTDTO.self, from: data) {
                    self.setToken(tokenData)
                }
            }
        }.resume()
    }
    
    func logoutFrom(completion: @escaping () -> Void) {
        guard let token = currentToken else {
            removeToken()
            completion()
            return
        }

        let endpoint = URL(string: "\(ConfigurationApp.API.keyCloak)/auth/realms/tuudr/protocol/openid-connect/logout")!
        let request = generateLogoutRequest(endpoint, token)
        URLSession.shared.dataTask(with: request) { [weak self] _, _, _ in
            DispatchQueue.main.async {
                self?.removeToken()
                completion()
            }
        }.resume()
    }
    
    private func generateLogoutRequest(_ endpoint: URL, _ token: AuthenticationJWTDTO) -> URLRequest {
        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = APIHTTPMethod.POST.rawValue
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [URLQueryItem]()
        requestBodyComponents.queryItems?.append(URLQueryItem(name: "client_id", value: "tuudr-frontend"))
        requestBodyComponents.queryItems?.append(URLQueryItem(name: "refresh_token", value: token.refreshToken))
        urlRequest.httpBody = requestBodyComponents.query?.data(using: .utf8)
        urlRequest.addValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
        return urlRequest
    }
}
