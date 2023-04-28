//
//  NetworkSession.swift
//  NetworkLayerRefact
//
//

import Foundation
import Combine

protocol NetworkSession: AnyObject {
    func publisher<T>(_ request: URLRequest, decodingType: T.Type, token: AuthenticationJWTDTO?) -> AnyPublisher<T, APIErrorHandler> where T: Decodable
}

extension URLSession: NetworkSession {
    func publisher<T>(_ request: URLRequest, decodingType: T.Type, token: AuthenticationJWTDTO?) -> AnyPublisher<T, APIErrorHandler> where T: Decodable {
        var newRequest = request
        newRequest.allHTTPHeaderFields?.removeValue(forKey: "Authorization")
        if let token = token?.accessToken {
            newRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return dataTaskPublisher(for: newRequest)
            .tryMap({ result in
                guard let httpResponse = result.response as? HTTPURLResponse else {
                    throw APIErrorHandler.requestFailed
                }
                
                if (200..<300) ~= httpResponse.statusCode {
                    return result.data
                } else if httpResponse.statusCode == 401 {
                    throw APIErrorHandler.tokenExpired
                } else {
                    if let error = try? JSONDecoder().decode(ApiErrorDTO.self, from: result.data) {
                        throw APIErrorHandler.customApiError(error)
                    } else {
                        throw APIErrorHandler.emptyErrorWithStatusCode(httpResponse.statusCode.description)
                    }
                }
            })
            .decode(type: T.self, decoder: customDateJSONDecoder)
            .mapError({ error -> APIErrorHandler in
                if let error = error as? APIErrorHandler {
                    return error
                }
                return APIErrorHandler.normalError(error)
            })
            .eraseToAnyPublisher()
    }
}

private let customDateJSONDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom(customDateDecodingStrategy)
    return decoder
}()

public func customDateDecodingStrategy(decoder: Decoder) throws -> Date {
    let container = try decoder.singleValueContainer()
    let str = try container.decode(String.self)
    return try Date.dateFromString(str)
}
