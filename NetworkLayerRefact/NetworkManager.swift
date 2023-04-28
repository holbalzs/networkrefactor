//
//  NetworkManager.swift
//  NetworkLayerRefact
//
//

import Foundation
import Combine
import SwiftUI

class NetworkManager: ObservableObject {
    private let session: NetworkSession
    var authenticator: Authenticator
        
    init(session: NetworkSession = URLSession.shared, auth: Authenticator) {
        self.session = session
        self.authenticator = auth
    }
    
    func performAuthenticatedRequest<T>(_ request: URLRequest, decodingType: T.Type) -> AnyPublisher<T, APIErrorHandler> where T: Decodable {
        return authenticator.validToken()
            .flatMap({ token in
                self.session.publisher(request, decodingType: decodingType, token: token)
            })
            .tryCatch({ error -> AnyPublisher<T, APIErrorHandler> in
                
                guard case APIErrorHandler.tokenExpired = error else {
                    throw error
                }
                
                return self.authenticator.validToken(forceRefresh: true)
                    .flatMap({ token in
                        // we can now use this new token to authenticate the second attempt at making this request
                        self.session.publisher(request, decodingType: decodingType, token: token)
                    })
                    .eraseToAnyPublisher()
            })
            .mapError({ error -> APIErrorHandler in
                if let error = error as? APIErrorHandler {
                    return error
                }
                return APIErrorHandler.normalError(error)
            })
        // .decode(type: decodingType, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
