//
//  DateExtension.swift
//  NetworkLayerRefact
//
//

import Foundation

internal extension Date {
    
    enum DateParserError: Error {
        case failedToParseDateFromString(String)
        case typeUnhandled(Any?)
    }
    
    // MARK: - Class
    
    static func dateFromString(_ string: Any?) throws -> Date {
        if let dateString = string as? String {            
            let count = dateString.count
            if count <= 10 {
                ISO8601DateFormatter.dateFormat = "yyyy-MM-dd"
            } else if count == 23 {
                ISO8601DateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
            } else if count == 19 {
                ISO8601DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            } else if count > 23 && dateString.contains("+") {
                ISO8601DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            } else {
                ISO8601DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
            }
            
            if let date = ISO8601DateFormatter.date(from: dateString) {
                return date
            } else {
                throw DateParserError.failedToParseDateFromString("String to parse: \(dateString), date format: \(String(describing: ISO8601DateFormatter.dateFormat))")
            }
        } else if let date = string as? Date {
            return date
        } else {
            throw DateParserError.typeUnhandled(string)
        }
    }
}

private let ISO8601DateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    let enUSPOSIXLocale = Locale(identifier: "en_US_POSIX")
    dateFormatter.locale = enUSPOSIXLocale
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    return dateFormatter
}()
