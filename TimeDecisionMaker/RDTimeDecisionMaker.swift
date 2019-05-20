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
        let organizerPerson = appoinmentsManager.loadEvents(from: organizerICS)
        let attendeePerson = appoinmentsManager.loadEvents(from: attendeeICS)
        
        var occupiedDateIntervals = [DateInterval]()
        populateWithPersonAppointments(organizerPerson, intervals: &occupiedDateIntervals)
        populateWithPersonAppointments(attendeePerson, intervals: &occupiedDateIntervals)
        
        return findDayFreeIntervalsFor(occupiedIntervals:
            occupiedDateIntervals.sorted { $0.start < $1.start }
            ).filter { $0.duration >= duration }
    }
    
    
    func suggestAppointmentsFor(organizer: RDPerson, attended: RDPerson, duration: TimeInterval) -> [DateInterval] {
        return suggestAppointments(organizerICS: organizer.appointmentsFilePath,
                                   attendeeICS: attended.appointmentsFilePath,
                                   duration: duration)
    }
    
    
    private func populateWithPersonAppointments(_ appointments: [RDAppointment], intervals: inout [DateInterval]) {
        for appointment in appointments {
            if appointment.isWholeDay || appointment.isDeleted { continue }
            
            if let _start = appointment.start, let _end = appointment.end {
                let occupiedInterval = DateInterval(start: _start, end: _end)
                
                if intervals.first(where: { $0.contains(interval: occupiedInterval) }) == nil {
                    intervals.removeAll { occupiedInterval.contains(interval: $0) }
                    intervals.append(occupiedInterval)
                }
            }
        }
    }
    
    
    private func findDayFreeIntervalsFor(occupiedIntervals: [DateInterval]) -> [DateInterval] {
        guard occupiedIntervals.count != 0,
            let dayStart = occupiedIntervals[0].start.changing(hour: 0, minute: 0, second: 0),
            let dayEnd = occupiedIntervals[occupiedIntervals.count - 1].end.changing(hour: 23, minute: 59, second: 59) else {
                return []
        }
        
        var freeIntervals = [DateInterval]()
        var previousDate = dayStart
        
        for occupied in occupiedIntervals {
            if previousDate < occupied.start {
                freeIntervals.append(DateInterval(start: previousDate, end: occupied.start))
            }
            
            previousDate = occupied.end
        }
        
        if previousDate <= dayEnd {
            freeIntervals.append(DateInterval(start: previousDate, end: dayEnd))
        }
        
        return freeIntervals
    }
}



extension DateInterval {
    func contains(interval other: DateInterval) -> Bool {
        return start < other.start && end > other.end
    }
}
