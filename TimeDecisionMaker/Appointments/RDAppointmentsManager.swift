

import Foundation


typealias PersonAppointments = (RDPerson, [RDAppointment])

class RDAppointmentsManager {
    func loadEvents(for person: RDPerson) -> [RDAppointment] {
        return loadEvents(from: person.appointmentsFilePath)
    }
    
    
    func loadEvents(from filePath: String) -> [RDAppointment] {
        let url = URL(fileURLWithPath: filePath)
        var appointments = [RDAppointment]()
        
        guard let calendars = try? iCal.load(url: url) else { return [] }
        
        for calendar in calendars {
            for component in calendar.subComponents {
                if let event = component as? Event {
                    let appointment = RDAppointment(uid: event.uid, title: event.summary, start: event.dtstart,
                                                    end: event.dtend, isWholeDay: event.isWholeDay)
                    appointments.append(appointment)
                }
            }
        }
        
        return appointments
    }
    
    
    func loadAllPersons() -> [PersonAppointments] {
        let fileExtension = "ics"
        let filePaths = Bundle.main.paths(forResourcesOfType: fileExtension, inDirectory: nil)
        var result = [(RDPerson, [RDAppointment])]()
        
        filePaths.forEach {
            result.append((RDPerson(appointmentsFilePath: $0), loadEvents(from: $0)))
        }
        
        return result
    }
    
    
    func updateEvents(for person: RDPerson, changing events: [RDAppointment]) {
        let fileUrl = URL(fileURLWithPath: person.appointmentsFilePath)
        iCal.updateEvents(for: fileUrl, changing: events)
    }
}
