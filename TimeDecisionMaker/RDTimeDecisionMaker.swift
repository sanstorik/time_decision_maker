//
//  RDTimeDecisionMaker.swift
//  TimeDecisionMaker
//
//  Created by Mikhail on 4/24/19.
//

import Foundation

class RDTimeDecisionMaker: NSObject {
    /// Main method to perform date interval calculation
    ///
    /// - Parameters:
    ///   - organizerICSPath: path to personA file with events
    ///   - attendeeICSPath: path to personB file with events
    ///   - duration: desired duration of appointment
    /// - Returns: array of available time slots, empty array if none found
    func suggestAppointments(organizerICS: String,
                             attendeeICS: String,
                             duration: TimeInterval) -> [DateInterval] {
        let appoinmentsManager = RDAppointmentsManager()
        let organizerPerson = appoinmentsManager.loadEvents(for: RDPerson(appointmentsFilePath: organizerICS))
        let attendeePerson = appoinmentsManager.loadEvents(for: RDPerson(appointmentsFilePath: attendeeICS))
        
        var occupiedDateIntervals = [DateInterval]()
        populateWithPersonAppointments(organizerPerson, intervals: &occupiedDateIntervals)
        populateWithPersonAppointments(attendeePerson, intervals: &occupiedDateIntervals)
        
        return findDayFreeIntervalsFor(occupiedIntervals: occupiedDateIntervals)
    }
    
    
    func suggestAppointmentsFor(organizer: RDPerson, attended: RDPerson, duration: TimeInterval) -> [DateInterval] {
        return suggestAppointments(organizerICS: organizer.appointmentsFilePath,
                                   attendeeICS: attended.appointmentsFilePath,
                                   duration: duration)
    }
    
    
    private func populateWithPersonAppointments(_ appointments: [RDAppointment], intervals: inout [DateInterval]) {
        
    }
    
    
    private func findDayFreeIntervalsFor(occupiedIntervals: [DateInterval]) -> [DateInterval] {
        return []
    }
}
