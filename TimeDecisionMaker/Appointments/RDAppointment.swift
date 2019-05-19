


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
