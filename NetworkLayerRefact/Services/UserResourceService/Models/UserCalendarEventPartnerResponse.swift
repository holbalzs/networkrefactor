//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

/** Elements of the page */
struct UserCalendarEventPartnerResponse: Codable {

    /** Counterpart's display name */
    public var displayName: String?

    /** The current user and other user has only waiting calender event */
    public var hasOnlyWaitingEvents: Bool?

    /** Number of the waiting calendar event */
    public var numberOfWaitingCalendarEvents: Int?

    /** Counterpart's pronouns */
    public var pronouns: String?

    /** Counterpart's thumbnail UUID */
    public var thumbnailUuid: String?

    /** Counterpart's ID */
    public var userId: Int?
}