//
//  InstructorAvailabilityProvider.swift
//  PADDTDR
//
//  Created by Holló Balázs on 2022. 12. 08..
//

import Foundation

enum InstructorAvailabilityProvider {
    case saveInstructorWeeklyAvailability(InstructorDailyAvailabilityRequest)
    case getInstructorWeeklyAvailability(Int)
    case getInstructorCalendar(Int, String)
    case getDaysAvailable(onlineSessionId: Int, date: String)
}

extension InstructorAvailabilityProvider: ApiEndpoint {
    var baseURLString: String {
        return ConfigurationApp.API.apiURL
    }
    
    var apiPath: String {
        return "api"
    }
    
    var apiVersion: String {
        "v1"
    }
    
    var separatorPath: String? {
        switch self {
        case .getInstructorWeeklyAvailability, .getInstructorCalendar, .getDaysAvailable:
            return "instructor-availability"
        default:
            return nil
        }
    }
    
    var path: String {
        switch self {
        case .saveInstructorWeeklyAvailability:
            return "instructor-availability"
        case .getInstructorWeeklyAvailability(let teacherId):
            return "\(teacherId)"
        case .getInstructorCalendar(let sessionId, let date):
            return "free-calendar-slots/\(sessionId)/\(date)"
        case .getDaysAvailable(let onlineSessionId, let date):
            return "free-calendar-days/\(onlineSessionId)/\(date)"
        }
    }
    
    var headers: [String: String]? {
        switch self {
        default:
            return ["Content-Type": "application/json"]
        }
    }
    
    var queryForCall: [URLQueryItem]? {
        switch self {
        default:
            return nil
        }
    }
    
    var params: [String: Any]? {
        switch self {
        case .saveInstructorWeeklyAvailability(let request):
            return request.asDictionary()
        default:
            return nil
        }
    }
    
    var method: APIHTTPMethod {
        switch self {
        case .getInstructorWeeklyAvailability, .getInstructorCalendar, .getDaysAvailable:
            return .GET
        case .saveInstructorWeeklyAvailability:
            return .PUT
        }
    }
    
    var customDataBody: Data? {
        return nil
    }
}
