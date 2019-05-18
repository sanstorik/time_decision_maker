import Foundation

/// TODO add documentation
internal class Parser {
    let icsContent: [String]

    init(_ ics: [String]) {
        icsContent = ics
    }

    func read() throws -> [Calendar] {
        var completeCal = [Calendar?]()

        // Such state, much wow
        var inCalendar = false
        var currentCalendar: Calendar?
        var inEvent = false
        var currentEvent: Event?
        var inAlarm = false
        var currentAlarm: Alarm?

        for (_ , line) in icsContent.enumerated() {
            if line.contains("BEGIN:VCALENDAR") {
                inCalendar = true
                currentCalendar = Calendar(withComponents: nil)
                continue
            } else if line.contains("END:VCALENDAR") {
                inCalendar = false
                completeCal.append(currentCalendar)
                currentCalendar = nil
                continue
            } else if line.contains("BEGIN:VEVENT") {
                inEvent = true
                currentEvent = Event()
                continue
            } else if line.contains("END:VEVENT") {
                inEvent = false
                currentCalendar?.append(component: currentEvent)
                currentEvent = nil
                continue
            } else if line.contains("BEGIN:VALARM") {
                inAlarm = true
                currentAlarm = Alarm()
                continue
            } else if line.contains("END:VALARM") {
                inAlarm = false
                currentEvent?.append(component: currentAlarm)
                currentAlarm = nil
                continue
            }
            
            guard let (key, value) = line.toKeyValuePair(splittingOn: ":") else {
                // print("(key, value) is nil") // DEBUG
                continue
            }

            if inCalendar && !inEvent {
                currentCalendar?.addAttribute(attr: key, value)
            }

            if inEvent && !inAlarm {
                currentEvent?.addAttribute(attr: key, value)
            }

            if inAlarm {
                currentAlarm?.addAttribute(attr: key, value)
            }
        }

        return completeCal.compactMap { $0 }
    }
}
