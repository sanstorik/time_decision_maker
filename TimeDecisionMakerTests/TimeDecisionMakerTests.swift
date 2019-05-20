//
//  TimeDecisionMakerTests.swift
//  TimeDecisionMakerTests
//
//  Created by Mikhail on 4/24/19.
//

import XCTest
@testable import TimeDecisionMaker

class TimeDecisionMakerTests: XCTestCase {

    lazy var organizerFilePath: String? = Bundle.main.path(forResource: "A", ofType: "ics")
    lazy var attendeeFilePath: String? = Bundle.main.path(forResource: "B", ofType: "ics")

    func testVeryLongAppointment() {
        let decisionMaker = RDTimeDecisionMaker()
        guard let orgPath = organizerFilePath, let attendeePath = attendeeFilePath else {
            XCTFail("Test files should exist")
            return
        }
        XCTAssertEqual([],
                       decisionMaker.suggestAppointments(organizerICS: orgPath,
                                                         attendeeICS: attendeePath,
                                                         duration: 24 * 60 * 60))
    }

    
    func testAtLeastOneHourAppointmentExist() {
        let decisionMaker = RDTimeDecisionMaker()
        guard let orgPath = organizerFilePath, let attendeePath = attendeeFilePath else {
            XCTFail("Test files should exist")
            return
        }
        XCTAssertNotEqual(0,
                          decisionMaker.suggestAppointments(organizerICS: orgPath,
                                                               attendeeICS: attendeePath,
                                                               duration: 3_600).count,
                          "At least one appointment should exist")
    }
    
    
    func testPerformanceForFindingSuggestions() {
        let decisionMaker = RDTimeDecisionMaker()
        let firstPath = createHugeICS(for: "Test1")
        let secondPath = createHugeICS(for: "Test2")
        
        measure {
            _ = decisionMaker.suggestAppointments(
                organizerICS: firstPath,
                attendeeICS: secondPath,
                duration: 30)
        }
    }
    
    
    private func createHugeICS(for name: String) -> String {
        var events = [Event]()
        var event = Event(uid: UUID().uuidString, dtstamp: Date())
        
        let startDate = Date()
        var prevEnd = startDate
        for i in 0..<1000 {
            event.dtstart = prevEnd
            prevEnd = Date(timeInterval: Double(i) * 60 * 5, since: startDate)
            event.dtend = prevEnd
            event.summary = "EXAMPLE"
            event.isWholeDay = i % 10 == 0
            events.append(event)
        }
        
        var path = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        path.appendPathComponent("\(name).ics")
        
        let calendar = RDCalendar(withComponents: events)
        try? calendar.toCal().write(to: path, atomically: true, encoding: .utf8)
        
        return path.path
    }
}
