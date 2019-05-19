

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
        fatalError()
    }
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground(AppColors.messengerBackgroundColor)
        setupNavigationBar(title: "Calendar", bgColor: AppColors.incomingMessageColor)
        setupViews()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add, target: self, action: #selector(newEvent))
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
        calendar.reloadEventData()
    }
    
    
    private func setupViews() {
        view.addSubview(calendar)
        
        calendar.eventsDelegate = self
        calendar.leadingAnchor.constraint(equalTo: view.leadingA).isActive = true
        calendar.trailingAnchor.constraint(equalTo: view.trailingA).isActive = true
        calendar.topAnchor.constraint(equalTo: view.topSafeAnchorIOS11(self)).isActive = true
        calendar.bottomAnchor.constraint(equalTo: view.bottomSafeAnchorIOS11(self)).isActive = true
    }
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .portraitUpsideDown]
    }
    
    
    override var shouldAutorotate: Bool { return false }
    
    
    private func filterAppointmentsBy(date: Date) -> [RDAppointment] {
        return appointments.filterByDate(date)
    }
    
    
    @objc private func newEvent() {
        let eventCreationVC = RDAppointmentCreationVC(
            RDAppointment(uid: UUID().uuidString, title: nil, start: Date(), end: Date(), isWholeDay: false))
        eventCreationVC.didChangeAppointment = { [unowned self] in
            self.appointmentsManager.updateEvents(for: self.person, changing: [RDAppointment(editModel: $0)])
        }
        
        let navigationVC = UINavigationController(rootViewController: eventCreationVC)
        self.present(navigationVC, animated: true)
    }
}


extension RDCalendarVC: EventsCalendarDelegate {
    func calendar(_ calendar: EventsCalendar, didSelect date: Date) {
        let personAppointmentsVC = RDPersonAppoinmentsVC(person: person, date: date)
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
