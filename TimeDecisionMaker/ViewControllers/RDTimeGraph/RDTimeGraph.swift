

import UIKit


class RDTimeGraph: UIView {
    private let hoursTexts = ["12", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11",
                      "Noon", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
    
    let zeroHourStartingHeight: CGFloat = 20
    let hourlineLeadingOffset: CGFloat = 63
    let oneHourHeight: CGFloat = 60
    let oneMinuteHeight: CGFloat = 1
    let settings: RDScheduledAppointmentSettings
    
    private(set) var innerAppointmentViews = [RDGraphAppointmentView]()
    private(set) var innerFreeIntervalViews = [RDGraphFreeIntervalView]()
    
    init(settings: RDScheduledAppointmentSettings) {
        self.settings = settings
        super.init(frame: .zero)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    func hourLabelFor(index: Int) -> String {
        return "\(hoursTexts[index]) \(index == 12 ? "" : (index <= 11 ? "AM" : "PM"))"
    }
    
    
    func placeAppointmentView(_ view: RDGraphAppointmentView) {
        guard let appointment = view.appointment else { return }
        view.isHidden = false
        let topConstant: CGFloat
        let heightConstant: CGFloat
        
        switch appointment.dateTypeFor(day: settings.date) {
        case .startingAndEndingToday(let start, let end):
            topConstant = appointmentStartingInsetFor(date: start)
            heightConstant = appointmentHeightFor(start: start, end: end)
        case .endingToday(let end):
            topConstant = zeroHourStartingHeight
            heightConstant = appointmentHeightFor(start: settings.date, end: end)
        case .startingToday(let start):
            topConstant = appointmentStartingInsetFor(date: start)
            let (hours, minutes) = start.retrieveHoursAndMinutes()
            heightConstant = appointmentHeightFor(minutes: 24 * 60 - (hours * 60 + minutes))
        case .isBetween(_, _):
            fallthrough
        case .wholeDay:
            fallthrough
        case .unknown:
            view.isHidden = true
            topConstant = 0
            heightConstant = 0
        }
        
        view.topConstraint.constant = topConstant
        view.heightConstraint.constant = heightConstant
        view.setNeedsLayout()
    }
    
    
    func placeFreeIntervalView(_ view: RDGraphFreeIntervalView) {
        guard let dateInterval = view.dateInterval else { return }
        
        view.topConstraint.constant = appointmentStartingInsetFor(date: dateInterval.start)
        view.heightConstraint.constant = appointmentHeightFor(start: dateInterval.start, end: dateInterval.end)
        view.setNeedsLayout()
    }
    
    
    func insertAppointment(_ view: RDGraphAppointmentView) {
        innerAppointmentViews.append(view)
        addSubview(view)
    }
    
    
    func insertFreeInterval(_ view: RDGraphFreeIntervalView) {
        innerFreeIntervalViews.append(view)
        addSubview(view)
    }
    
    
    final func createHourLines(linkedTo scrollViewBottomAnchor: NSLayoutYAxisAnchor) {
        var currentTopAnchor = self.topAnchor
        var spacing: CGFloat = 5
        for i in 0...24 {
            let hourLine = createHourLine(topAnchor: currentTopAnchor, spacing: spacing, index: i)
            currentTopAnchor = hourLine.bottomAnchor
            spacing = 30
            
            if i == 24 {
                hourLine.bottomAnchor.constraint(equalTo: scrollViewBottomAnchor).isActive = true
            }
        }
    }
    
    
    private func appointmentStartingInsetFor(date: Date) -> CGFloat {
        let (hour, minute) = date.retrieveHoursAndMinutes()
        return zeroHourStartingHeight + CGFloat(hour) * oneHourHeight + CGFloat(minute) * oneMinuteHeight
    }
    
    
    private func appointmentHeightFor(start: Date, end: Date) -> CGFloat {
        let (hour, minute) = start.retrieveHoursAndMinutes()
        let (endHour, endMinute) = end.retrieveHoursAndMinutes()
        
        let durationInMinutes = (endHour * 60 + endMinute) - (hour * 60 + minute)
        return CGFloat(durationInMinutes) * oneMinuteHeight
    }
    
    
    private func appointmentHeightFor(minutes: Int) -> CGFloat {
        return CGFloat(minutes) * oneMinuteHeight
    }
    
    
    private func createHourLine(topAnchor: NSLayoutYAxisAnchor, spacing: CGFloat, index: Int) -> RDGraphHourLine {
        let view = RDGraphHourLine()
        addSubview(view)
        view.hourLabel.text = hourLabelFor(index: index)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: topAnchor, constant: spacing).isActive = true
        view.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        return view
    }
}
