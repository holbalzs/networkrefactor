//
//  AuthenticationJWTDTO.swift
//  NetworkLayerRefact
//
//

import Foundation

struct AuthenticationJWTDTO: Codable {
    let accessToken: String
    let expiresIn, refreshExpiresIn: Int
    let refreshToken, tokenType: String
    let notBeforePolicy: Int
    let sessionState, scope: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case refreshExpiresIn = "refresh_expires_in"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
        case notBeforePolicy = "not-before-policy"
        case sessionState = "session_state"
        case scope
    }
}

struct JWTTokenModel: Codable {
    let exp: Double
    let name: String?
    let given_name: String?
    let family_name: String?
}

extension AuthenticationJWTDTO {
    func isValid() -> Bool {
        guard let accessModel = getJWTtokenModel(accessToken) else { return false }
        return !isTokenDateExpired(timeInterval: accessModel.exp)
    }

    func refreshIsValid() -> Bool {
        guard let refreshModel = getJWTtokenModel(refreshToken) else { return false }
        return !isTokenDateExpired(timeInterval: refreshModel.exp)
    }

    private func getJWTtokenModel(_ token: String) -> JWTTokenModel? {
        let segments = token.components(separatedBy: ".")
        var base64String = segments[1]
        let requiredLength = Int(4 * ceil(Float(base64String.count) / 4.0))
        let nbrPaddings = requiredLength - base64String.count
        if nbrPaddings > 0 {
            let padding = String().padding(toLength: nbrPaddings, withPad: "=", startingAt: 0)
            base64String = base64String.appending(padding)
        }
        base64String = base64String.replacingOccurrences(of: "-", with: "+")
        base64String = base64String.replacingOccurrences(of: "_", with: "/")
        let decodedData = Data(base64Encoded: base64String, options: Data.Base64DecodingOptions(rawValue: UInt(0)))

        guard let decodedData = decodedData else {
            return nil
        }
        return try? JSONDecoder().decode(JWTTokenModel.self, from: decodedData)
    }

    private func isTokenDateExpired(timeInterval: Double) -> Bool {
        let expiringDate = Date(timeIntervalSince1970: timeInterval)
#if DEBUG
        //debugLog(expiringDate)
#endif
        return Date() > expiringDate
    }
    
    func getNameFromToken() -> String? {
        return getJWTtokenModel(accessToken)?.name
    }
}
