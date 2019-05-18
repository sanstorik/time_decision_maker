

import Foundation



class RDAppointmentsManager {
    func loadEvents(for person: RDPerson) -> [RDAppointment] {
        if let filePath = person.appointmentsFilePath {
            return loadEvents(from: filePath)
        } else {
            return []
        }
    }
    
    
    func loadEvents(from filePath: String) -> [RDAppointment] {
        let url = URL(fileURLWithPath: filePath)
        var appointments = [RDAppointment]()
        
        guard let calendars = try? iCal.load(url: url) else { return [] }
        
        for calendar in calendars {
            for component in calendar.subComponents {
                if let event = component as? Event {
                    let appointment = RDAppointment(title: event.summary, start: event.dtstart, end: event.dtend)
                    appointments.append(appointment)
                }
            }
        }
        
        return appointments
    }
    
    
    func loadAllPersons() -> [(RDPerson, [RDAppointment])] {
        return []
    }
}
