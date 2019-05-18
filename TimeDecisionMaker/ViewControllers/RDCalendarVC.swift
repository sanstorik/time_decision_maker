

import UIKit

class RDCalendarVC: CommonVC {
    private let calendar: CalendarView = EventsCalendar(frame: CGRect.zero)
    private let appointmentsManager = RDAppointmentsManager()
    private var appointments = [RDAppointment]()
    private let person: RDPerson
    private var previouslySelectedDate: Date?
    
    
    init(person: RDPerson) {
        self.person = person
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        self.person = RDPerson(appointmentsFilePath: nil)
        super.init(coder: aDecoder)
    }
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground(AppColors.messengerBackgroundColor)
        setupNavigationBar(title: "Calendar", bgColor: AppColors.incomingMessageColor)
        setupViews()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appointments = appointmentsManager.loadEvents(for: person)
        
        let selectedDate: Date
        if let cached = previouslySelectedDate {
            selectedDate = cached
        } else if let firstAppointment = appointments.filter({ $0.start != nil }).min(by: { $0.start! < $1.start! }) {
            selectedDate = firstAppointment.start!
        } else {
            selectedDate = Date()
        }
        
        previouslySelectedDate = selectedDate
        calendar.selectDate(selectedDate)
    }
    
    
    private func setupViews() {
        view.addSubview(calendar)
        
        calendar.eventsDelegate = self
        calendar.leadingAnchor.constraint(equalTo: view.leadingA).isActive = true
        calendar.trailingAnchor.constraint(equalTo: view.trailingA).isActive = true
        calendar.topAnchor.constraint(equalTo: view.topSafeAnchorIOS11(self)).isActive = true
        calendar.bottomAnchor.constraint(equalTo: view.bottomSafeAnchorIOS11(self)).isActive = true
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animateAlongsideTransition(in: nil, animation: nil) { _ in
            self.calendar.recalculateRowsHeight(for: size.height - 10)
        }
        
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    
    private func filterAppointmentsBy(date: Date) -> [RDAppointment] {
        return appointments.filterByDate(date)
    }
}


extension RDCalendarVC: EventsCalendarDelegate {
    func calendar(_ calendar: EventsCalendar, didSelect date: Date) {
        let personAppointmentsVC = RDPersonAppoinmentsVC(person: person, appointments: appointments, date: date)
        navigationController?.pushViewController(personAppointmentsVC, animated: true)
        previouslySelectedDate = date
    }
    
    
    func calendar(_ calendar: EventsCalendar, numberOfEventsFor date: Date) -> Int {
        return filterAppointmentsBy(date: date).count
    }
    
    
    func calendar(_ calendar: EventsCalendar, eventDefaultColorsFor date: Date) -> [UIColor]? {
        return [UIColor.white, UIColor.white]
    }
    
    
    func calendar(_ calendar: EventsCalendar, willDisplay cell: EventsCalendarDateCell, for date: Date) {
        
    }
    
    
    func calendar(_ calendar: EventsCalendar, eventSelectionColorsFor date: Date) -> [UIColor]? {
        return filterAppointmentsBy(date: date).map { _ in AppColors.colorPrimaryLight }
    }
}
