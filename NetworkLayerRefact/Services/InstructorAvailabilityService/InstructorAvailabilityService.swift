//
//  InstructorAvailabilityService.swift
//  PADDTDR
//
//  Created by Holló Balázs on 2022. 12. 08..
//

import Foundation
import Combine

protocol InstructorAvailabilityServiceProtocol: AnyObject {
    func getInstructorWeeklyAvailability(teacherId: Int) -> AnyPublisher<InstructorDailyAvailabilityResponse, APIErrorHandler>
    func getInstructorCalendar(sessionId: Int, date: String) -> AnyPublisher<[CalendarSlotResponse], APIErrorHandler>
    func getDaysAvailable(onlineSessionId: Int, date: String) -> AnyPublisher<[DayAvailableResponse], APIErrorHandler>
}

class InstructorAvailabilityService: InstructorAvailabilityServiceProtocol {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func getInstructorWeeklyAvailability(teacherId: Int) -> AnyPublisher<InstructorDailyAvailabilityResponse, APIErrorHandler> {
        let request = InstructorAvailabilityProvider.getInstructorWeeklyAvailability(teacherId).makeRequest
        return networkManager.performAuthenticatedRequest(request, decodingType: InstructorDailyAvailabilityResponse.self)
    }
    
    func getInstructorCalendar(sessionId: Int, date: String) -> AnyPublisher<[CalendarSlotResponse], APIErrorHandler> {
        let request = InstructorAvailabilityProvider.getInstructorCalendar(sessionId, date).makeRequest
        return networkManager.performAuthenticatedRequest(request, decodingType: [CalendarSlotResponse].self)
    }
    
    func getDaysAvailable(onlineSessionId: Int, date: String) -> AnyPublisher<[DayAvailableResponse], APIErrorHandler> {
        let request = InstructorAvailabilityProvider.getDaysAvailable(onlineSessionId: onlineSessionId, date: date).makeRequest
        return networkManager.performAuthenticatedRequest(request, decodingType: [DayAvailableResponse].self)
    }
}
