//
//  Encodable+Extension.swift
//  NetworkLayerRefact
//
//

import Foundation

extension Encodable {
    /// Object to dictionary
    func asDictionary() -> [String: Any]? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom(customDateEncodingStrategy)
        guard
            let data = try? encoder.encode(self),
            let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
        else {
            return nil
        }
        return dictionary
    }
}

private func customDateEncodingStrategy(date: Date, encoder: Encoder) throws {
    let formatter = DateFormatter()
//    let enUSPOSIXLocale = Locale(identifier: "en_US_POSIX")
//    formatter.locale = enUSPOSIXLocale
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
    let stringData = formatter.string(from: date)
    var container = encoder.singleValueContainer()
    return try container.encode(stringData)
}
