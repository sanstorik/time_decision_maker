


import Foundation


class RDAppointmentEditModel {
    var title: String?
    var start: Date?
    var end: Date?
    var isWholeDay: Bool
    let uid: String
    
    init(uid: String, title: String?, start: Date?, end: Date?, isWholeDay: Bool) {
        self.uid = uid
        self.title = title
        self.start = start
        self.end = end
        self.isWholeDay = isWholeDay
    }
    
    init(appointment: RDAppointment) {
        self.uid = appointment.uid
        self.title = appointment.title
        self.start = appointment.start
        self.end = appointment.end
        self.isWholeDay = appointment.isWholeDay
    }
}


struct RDAppointment {
    enum EventDateType {
        case startingAndEndingToday(Date, Date)
        case startingToday(Date)
        case endingToday(Date)
        case isBetween(Date, Date)
        case wholeDay
        case unknown
    }
    
    let title: String?
    let start: Date?
    let end: Date?
    let isWholeDay: Bool
    let uid: String
    
    init(uid: String, title: String?, start: Date?, end: Date?, isWholeDay: Bool) {
        self.uid = uid
        self.title = title
        self.start = start
        self.end = end
        self.isWholeDay = isWholeDay
    }
    
    init(editModel: RDAppointmentEditModel) {
        self.uid = editModel.uid
        self.title = editModel.title
        self.start = editModel.start
        self.end = editModel.end
        self.isWholeDay = editModel.isWholeDay
    }
    
    
    func dateTypeFor(day date: Date) -> EventDateType {
        let type: EventDateType
        if isWholeDay {
            return .wholeDay
        } else if let _start = start, let _end = end {
            if _start.sameDay(with: date), _end.sameDay(with: date) {
                type = .startingAndEndingToday(_start, _end)
            } else if _start.sameDay(with: date) {
                type = .startingToday(_start)
            } else if _end.sameDay(with: date) {
                type = .endingToday(_end)
            } else if date.isBetween(from: _start, to: _end) {
                type = .isBetween(_start, _end)
            } else {
                type = .unknown
            }
        } else {
            type = .unknown
        }
        
        return type
    }
}


extension Array where Element == RDAppointment {
    func sortedByStartDate() -> [RDAppointment] {
        let (wholeDay, regular) = sortedByStartDate()
        return wholeDay + regular
    }
    
    
    func sortedByStartDate() -> ([RDAppointment], [RDAppointment]) {
        var wholeDayEvents = [RDAppointment]()
        var defaultEvents = [RDAppointment]()
        
        forEach {
            if $0.isWholeDay {
                wholeDayEvents.append($0)
            } else {
                defaultEvents.append($0)
            }
        }
        
        return (wholeDayEvents, defaultEvents.sortedByDate())
    }
    
    
    private mutating func sortedByDate() -> [RDAppointment] {
        return sorted {
            if let lhs = $0.start, let rhs = $1.start {
                return lhs < rhs
            } else {
                return $0.start != nil
            }
        }
    }
    
    
    func filterByDate(_ date: Date) -> [RDAppointment] {
        return filter {
            if let start = $0.start, let end = $0.end {
                return date.isBetween(from: start, to: end)
            } else if let start = $0.start {
                return date.compareDay(to: start) == .orderedSame
            } else if let end = $0.end {
                return date.compareDay(to: end) == .orderedSame
            }
            
            return false
        }
    }
}
