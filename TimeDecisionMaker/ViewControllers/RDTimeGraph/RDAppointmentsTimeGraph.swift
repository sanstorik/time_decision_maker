
import UIKit

protocol RDNavigation: class {
    func present(viewController: UIViewController)
    func pushViewContoller(_ viewController: UIViewController)
}

protocol RDAppointmentGraphDelegate: class {
    func didSelectDateInterval(_ dateInterval: DateInterval, person: RDPerson)
    func didChangeAppointment(_ editModel: RDAppointmentEditModel, person: RDPerson)
    func didDeleteAppointment(_ editModel: RDAppointmentEditModel, person: RDPerson)
}


class RDAppointmentTimeGraph: CommonVC, RDNavigation, RDAppointmentGraphDelegate {
    private let personsData: [PersonAppointments]
    private let appointmentsManager = RDAppointmentsManager()
    private let timeDecisionMaker = RDTimeDecisionMaker()
    private var scrollView: UIScrollView!
    private var graph: RDTimeGraph!
    private var settings: RDScheduledAppointmentSettings
    
    
    init(personsData: [PersonAppointments], settings: RDScheduledAppointmentSettings) {
        self.settings = settings
        self.personsData = personsData
        super.init(nibName: nil, bundle: nil)
    }

    
    required init?(coder aDecoder: NSCoder) {
        self.personsData = []
        self.settings = RDScheduledAppointmentSettings()
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar(title: settings.date.readableDateString(), bgColor: AppColors.incomingMessageColor)
        setupBackground(AppColors.messengerBackgroundColor)
        setupViews()
    }
    
    
    private func setupViews() {
        scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.leadingAnchor.constraint(equalTo: view.leadingA).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingA).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topSafeAnchorIOS11(self)).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomSafeAnchorIOS11(self)).isActive = true
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.isScrollEnabled = true
        scrollView.isUserInteractionEnabled = true
        
        graph = RDTimeGraph(settings: settings)
        scrollView.addSubview(graph)
        graph.translatesAutoresizingMaskIntoConstraints = false
        graph.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        graph.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        graph.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        graph.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        graph.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        graph.createHourLines(linkedTo: scrollView.bottomAnchor)
        
        for (i, personData) in self.personsData.enumerated() {
            if i == 4 { break }
            
            let isSender = i % 2 == 0
            for appointment in personData.appointments {
                let appointmentView = RDGraphAppointmentView(inside: graph)
                appointmentView.appointmentGraphDelegate = self
                appointmentView.navigationDelegate = self
                appointmentView.appointment = appointment
                appointmentView.person = personData.person
                
                let bgColor = isSender ? AppColors.labelOrderFillerColor.withAlphaComponent(0.1) : AppColors.lightBlueColor
                let mode: RDGraphRect.Mode = personsData.count == 1 ? .full : (isSender ? .left : .right)
                let theme = RDGraphAppointmentView.Theme(backgroundColor: bgColor, mode: mode)
                appointmentView.theme = theme
            }
        }
        
        setupFreeDatesSuggestions()
    }
    
    
    func present(viewController: UIViewController) {
        self.present(viewController, animated: true)
    }
    
    
    func pushViewContoller(_ viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    func didChangeAppointment(_ editModel: RDAppointmentEditModel, person: RDPerson) {
        let updatedAppointment = RDAppointment(editModel: editModel)
        appointmentsManager.updateEvents(for: person, changing: [updatedAppointment])
        
        if let viewToBeUpdated = graph.innerAppointmentViews.first(where: { $0.appointment?.uid == editModel.uid }) {
            viewToBeUpdated.appointment = updatedAppointment
            graph.removeDatesSuggestions()
            setupFreeDatesSuggestions()
        }
    }

    
    func didDeleteAppointment(_ editModel: RDAppointmentEditModel, person: RDPerson) {
        let updatedAppointment = RDAppointment(editModel: editModel)
        appointmentsManager.updateEvents(for: person, changing: [updatedAppointment])
        
        if let deletedIndex = graph.innerAppointmentViews.firstIndex(where: { $0.appointment?.uid == editModel.uid }) {
            graph.removeDeletedAppointmentView(at: deletedIndex)
            graph.removeDatesSuggestions()
            setupFreeDatesSuggestions()
        }
    }
    
    
    func didSelectDateInterval(_ dateInterval: DateInterval, person: RDPerson) {
        let isEndingToday = !dateInterval.start.sameDay(with: settings.date)
            && dateInterval.end.sameDay(with: settings.date)
        
        var startingDate: Date = dateInterval.start
        if isEndingToday {
            if let _startOfTheDay = dateInterval.end.changing(hour: 0, minute: 0, second: 0) {
                startingDate = _startOfTheDay
            }
        }
        
        let eventCreationVC = RDAppointmentCreationVC(
            RDAppointment(uid: UUID().uuidString, title: nil, start: startingDate,
                          end: startingDate.addingTimeInterval(self.settings.duration), isWholeDay: false))
        
        eventCreationVC.didChangeAppointment = { [unowned self] in
            let newAppointment = RDAppointment(editModel: $0)
            self.appointmentsManager.updateEvents(for: person, changing: [newAppointment])
            let appointmentView = RDGraphAppointmentView(inside: self.graph)
            appointmentView.appointmentGraphDelegate = self
            appointmentView.navigationDelegate = self
            appointmentView.appointment = newAppointment
            appointmentView.person = person
            appointmentView.theme = .defaultTheme
            
            self.graph.removeDatesSuggestions()
            self.setupFreeDatesSuggestions()
        }
        
        let navigationVC = UINavigationController(rootViewController: eventCreationVC)
        self.present(navigationVC, animated: true)
    }
    
    
    private func setupFreeDatesSuggestions() {
        guard personsData.count == 2 else {
            return
        }
        
        let organizer = personsData[0].person
        let attendee = personsData[1].person
        let suggestedFreeDateIntervals = timeDecisionMaker.suggestAppointmentsFor(
            organizer: organizer, attendee: attendee, duration: settings.duration)
            .filter { shouldDateIntervalBeDisplayed($0, for: settings.date) }
        
        suggestedFreeDateIntervals.forEach {
            createFreeInterval(dateInterval: $0, person: organizer)
        }
    }
    
    
    private func createFreeInterval(dateInterval: DateInterval, person: RDPerson) {
        let freeInterval = RDGraphFreeIntervalView(inside: graph)
        freeInterval.appointmentGraphDelegate = self
        freeInterval.navigationDelegate = self
        freeInterval.dateInterval = dateInterval
        freeInterval.person = person
    }
    
    
    private func shouldDateIntervalBeDisplayed(_ dateInterval: DateInterval, for date: Date) -> Bool {
        let sameDay = dateInterval.start.sameDay(with: date) && dateInterval.end.sameDay(with: date)
        let startingToday = dateInterval.start.sameDay(with: date) && !dateInterval.end.sameDay(with: date)
        let endingToday = !dateInterval.start.sameDay(with: date) && dateInterval.end.sameDay(with: date)
        let between = date.isBetween(from: dateInterval.start, to: dateInterval.end)
        return sameDay || startingToday || endingToday || between
    }
}
