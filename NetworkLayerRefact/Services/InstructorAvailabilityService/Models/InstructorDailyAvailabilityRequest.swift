//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

struct InstructorDailyAvailabilityRequest: Codable {

    /** Day of week in number */
    public var dayOfWeek: Int

    public var times: [InstructorIntervalRequest]
}
