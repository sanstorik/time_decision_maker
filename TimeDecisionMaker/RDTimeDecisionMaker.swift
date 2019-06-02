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
            let dayEnd = getRealEndDateFor(dateIntervals: occupiedIntervals)
            else {
                return []
        }
        
        var freeIntervals = [DateInterval]()
        var previousDate = dayStart
        
        for occupied in occupiedIntervals {
            if previousDate < occupied.start {
                let expectedFreeInterval = DateInterval(start: previousDate, end: occupied.start)
                if !occupied.start.sameDay(with: occupied.end) {
                    /**
                     *  For appointments that last for more than 1 day we take the starting day free interval
                     *  plus the ending day free interval. Disperse the interval (previous date - start date)
                     *  into single day pieces. Calculating start / end of the day free intervals depending on
                     *  whether previous and current occupied intervals take place in one day.
                     */
                    
                    if !expectedFreeInterval.start.sameDay(with: expectedFreeInterval.end),
                        let _firstIntervalEnd = expectedFreeInterval.start.changing(hour: 23, minute: 59, second: 59)  {
                        let interval = DateInterval(start: expectedFreeInterval.start, end: _firstIntervalEnd)
                        addIfNeededTo(&freeIntervals, interval: interval, expected: duration)
                    }
                    
                    if let _lastIntervalStart = expectedFreeInterval.start.sameDay(with: expectedFreeInterval.end) ?
                        expectedFreeInterval.start : expectedFreeInterval.end.changing(hour: 0, minute: 0, second: 0) {
                        let interval = DateInterval(start: _lastIntervalStart, end: expectedFreeInterval.end)
                        addIfNeededTo(&freeIntervals, interval: interval, expected: duration)
                    }
                    
                    freeIntervals += breakLongIntervalIntoSingleDayPieces(expectedFreeInterval, expected: duration)
                } else if !expectedFreeInterval.start.sameDay(with: expectedFreeInterval.end) {
                    /**
                     *  Break long intervals into single day pieces
                     *  That happens when the difference between the previous and the next appointment
                     *  is bigger than 1 day.
                     */

                    if let _firstIntervalEnd = expectedFreeInterval.start.changing(hour: 23, minute: 59, second: 59) {
                        let interval = DateInterval(start: expectedFreeInterval.start, end: _firstIntervalEnd)
                        addIfNeededTo(&freeIntervals, interval: interval, expected: duration)
                    }
                    
                    if let _lastIntervalStart = expectedFreeInterval.end.changing(hour: 0, minute: 0, second: 0) {
                        let interval = DateInterval(start: _lastIntervalStart, end: expectedFreeInterval.end)
                        addIfNeededTo(&freeIntervals, interval: interval, expected: duration)
                    }
                    
                    freeIntervals += breakLongIntervalIntoSingleDayPieces(expectedFreeInterval, expected: duration)
                } else {
                    addIfNeededTo(&freeIntervals, interval: expectedFreeInterval, expected: duration)
                }
            }
            
            if previousDate <= occupied.end {
                previousDate = occupied.end
            }
        }
        
        if previousDate <= dayEnd {
            let dt = DateInterval(start: previousDate, end: dayEnd)
            addIfNeededTo(&freeIntervals, interval: dt, expected: duration)
        }
        
        return freeIntervals
    }
    
    
    private func getRealEndDateFor(dateIntervals: [DateInterval]) -> Date? {
        return dateIntervals.max { $0.end < $1.end }?.end.changing(hour: 23, minute: 59, second: 59)
    }
    
    
    private func addIfNeededTo(_ dateIntervals: inout [DateInterval], interval: DateInterval, expected duration: TimeInterval) {
        if interval.duration >= duration {
            dateIntervals.append(interval)
        }
    }
    
    
    private func breakLongIntervalIntoSingleDayPieces(_ interval: DateInterval, expected duration: TimeInterval) -> [DateInterval] {
        guard var currentDay = interval.start.nextDay(), !interval.start.sameDay(with: interval.end) else { return [] }
        var singleDayIntervals = [DateInterval]()
        
        while !currentDay.sameDay(with: interval.end) {
            if let _endDate = currentDay.changing(hour: 23, minute: 59, second: 59) {
                let singleDayInterval = DateInterval(start: currentDay, end: _endDate)
                addIfNeededTo(&singleDayIntervals, interval: singleDayInterval, expected: duration)
            }
            
            if let _nextDate = currentDay.nextDay() {
                currentDay = _nextDate
            } else {
                return singleDayIntervals
            }
        }
        
        return singleDayIntervals
    }
}
