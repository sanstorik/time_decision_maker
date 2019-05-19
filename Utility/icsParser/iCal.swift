import Foundation

public enum iCal {
    /// Loads the content of a given string.
    ///
    /// - Parameter string: string to load
    /// - Returns: List of containted `Calendar`s
    public static func load(string: String) -> [Calendar] {
        let icsContent = string.components(separatedBy: "\n")
        return parse(icsContent)
    }

    /// Loads the contents of a given URL. Be it from a local path or external resource.
    ///
    /// - Parameters:
    ///   - url: URL to load
    ///   - encoding: Encoding to use when reading data, defaults to UTF-8
    /// - Returns: List of contained `Calendar`s.
    /// - Throws: Error encountered during loading of URL or decoding of data.
    /// - Warning: This is a **synchronous** operation! Use `load(string:)` and fetch your data beforehand for async handling.
    public static func load(url: URL, encoding: String.Encoding = .utf8) throws -> [Calendar] {
        let data = try Data(contentsOf: url)
        guard let string = String(data: data, encoding: encoding) else { throw iCalError.encoding }
        return load(string: string)
    }
    
    
    static func updateEvents(for url: URL, changing appointments: [RDAppointment]) {
        if let calendars = try? load(url: url) {
            let updatedCalendars = calendars.map { updatedCalendar($0, with: appointments) }
            
            var icsResult = ""
            updatedCalendars.forEach {
                icsResult.append($0.toCal())
            }
            
            try? icsResult.write(to: url, atomically: true, encoding: .utf8)
        }
    }
    
    
    private static func updatedCalendar(_ calendar: Calendar, with appointments: [RDAppointment]) -> Calendar {
        var updatedCalendar = calendar
        var updatedComponents = [CalendarComponent]()
        
        for component in calendar.subComponents {
            guard let event = component as? Event, let match = appointments.first(where: { $0.uid == event.uid }) else {
                updatedComponents.append(component)
                continue
            }
            
            var updatedEvent = event
            updatedEvent.summary = match.title
            updatedEvent.dtstart = match.start
            updatedEvent.dtend = match.end
            updatedEvent.isWholeDay = match.isWholeDay
            updatedComponents.append(updatedEvent)
        }
        
        updatedCalendar.subComponents = updatedComponents
        return updatedCalendar
    }
    

    private static func parse(_ icsContent: [String]) -> [Calendar] {
        let parser = Parser(icsContent)
        do {
            return try parser.read()
        } catch let error {
            print(error)
            return []
        }
    }

    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter
    }()
    
    
    static let wholeDayDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter
    }()
}
