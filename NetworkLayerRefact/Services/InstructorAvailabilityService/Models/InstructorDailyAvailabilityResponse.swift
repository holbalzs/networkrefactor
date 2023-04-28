//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

struct InstructorDailyAvailabilityResponse: Codable {

    /** Day of week in number */
    public var dayOfWeek: Int?

    public var times: [InstructorIntervalResponse]?
}

struct CalendarSlotResponse: Codable {

    /** End of time */
    public enum `Type`: String, Codable, Equatable, CaseIterable {
        case teacherUnavailable = "TEACHER_UNAVAILABLE"
        case studentUnavailable = "STUDENT_UNAVAILABLE"
        case available = "AVAILABLE"
    }

    /** End of time */
    public var time: String?

    /** End of time */
    public var type: `Type`?
}