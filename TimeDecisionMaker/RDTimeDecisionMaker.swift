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
        
        return findFreeIntervalsFor(
            occupiedIntervals: occupiedDateIntervals.sorted { $0.start < $1.start },
            expectedDuration: duration
            )
    }
    
    
    func suggestAppointmentsFor(organizer: RDPerson, attended: RDPerson, duration: TimeInterval) -> [DateInterval] {
        return suggestAppointments(organizerICS: organizer.appointmentsFilePath,
                                   attendeeICS: attended.appointmentsFilePath,
                                   duration: duration)
    }
    
    
    private func populateWithPersonAppointments(_ appointments: [RDAppointment], intervals: inout [DateInterval]) {
        for appointment in appointments where !appointment.isWholeDay && !appointment.isDeleted {
            if let _start = appointment.start, let _end = appointment.end {
                intervals.append(DateInterval(start: _start, end: _end))
            }
        }
    }
    
    
    private func findFreeIntervalsFor(
        occupiedIntervals: [DateInterval],
        expectedDuration duration: TimeInterval) -> [DateInterval] {
        /**
         *  Start date - first sorted day with HH:mm:ss set to 00:00:00
         *  End date - last sorted day HH:mm:ss set to 23:59:59
         *  28.04.18 00:00:00 - 30.04.18 23:59:59
         */
        guard occupiedIntervals.count != 0,
            let dayStart = occupiedIntervals[0].start.changing(hour: 0, minute: 0, second: 0),
            let dayEnd = occupiedIntervals[occupiedIntervals.count - 1].end.changing(hour: 23, minute: 59, second: 59)
            else {
                return []
        }
        
        var freeIntervals = [DateInterval]()
        var previousDate = dayStart
        
        for occupied in occupiedIntervals {
            if previousDate < occupied.start {
                let dt = DateInterval(start: previousDate, end: occupied.start)
                if dt.duration >= duration {
                    freeIntervals.append(dt)
                }
            }
            
            if previousDate <= occupied.end {
                previousDate = occupied.end
            }
        }
        
        if previousDate <= dayEnd {
            let dt = DateInterval(start: previousDate, end: dayEnd)
            if dt.duration >= duration {
                freeIntervals.append(dt)
            }
        }
        
        return freeIntervals
    }
}
