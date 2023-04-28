//
//  APIErrorHandler.swift
//  NetworkLayerRefact
//
//

import Foundation

struct ApiErrorDTO: Codable {
    let code: String?
    let message: String?
    let errorItems: [String: String]?
}

enum APIErrorHandler: Error {
    case customApiError(ApiErrorDTO)
    case requestFailed
    case normalError(Error)
    case tokenExpired
    case emptyErrorWithStatusCode(String)

    var errorDescription: String? {
        switch self {
        case .customApiError(let apiErrorDTO):
            var errorItems: String?
            if let errorItemsDTO = apiErrorDTO.errorItems {
                errorItems = ""
                errorItemsDTO.forEach {
                    errorItems?.append($0.key)
                    errorItems?.append(" ")
                    errorItems?.append($0.value)
                    errorItems?.append("\n")
                }
            }
            if errorItems == nil && apiErrorDTO.code == nil && apiErrorDTO.message == nil {
                errorItems = "Internal error!"
            }
            return String(format: "%@ %@ \n %@", apiErrorDTO.code ?? "", apiErrorDTO.message ?? "", errorItems ?? "")
        case .requestFailed:
            return "request failed"
        case .normalError(let error):
            return error.localizedDescription
        case .tokenExpired:
            return "Token problems"
        case .emptyErrorWithStatusCode(let status):
            return status
        }
    }
}
