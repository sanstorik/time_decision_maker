
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
            
            for appointment in personData.appointments {
                let appointmentView = RDGraphAppointmentView(inside: graph)
                appointmentView.appointmentGraphDelegate = self
                appointmentView.navigationDelegate = self
                appointmentView.appointment = appointment
                appointmentView.person = personData.person
                appointmentView.theme = i % 2 == 0 ?
                    .defaultTheme : RDGraphAppointmentView.Theme(backgroundColor:
                        AppColors.lightBlueColor, textAlignment: .right)
            }
        }
        
        if personsData.count == 2 {
            let organizer = personsData[0].person
            let attendee = personsData[1].person
            let suggestedFreeDateIntervals = timeDecisionMaker.suggestAppointmentsFor(
                organizer: organizer, attended: attendee, duration: settings.duration)
            
            suggestedFreeDateIntervals.forEach {
                let freeInterval = RDGraphFreeIntervalView(inside: graph)
                freeInterval.appointmentGraphDelegate = self
                freeInterval.navigationDelegate = self
                freeInterval.dateInterval = $0
                freeInterval.person = organizer
            }
        }
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
        }
    }
    
    
    func didDeleteAppointment(_ editModel: RDAppointmentEditModel, person: RDPerson) {
        let updatedAppointment = RDAppointment(editModel: editModel)
        appointmentsManager.updateEvents(for: person, changing: [updatedAppointment])
        
        if let deletedIndex = graph.innerAppointmentViews.firstIndex(where: { $0.appointment?.uid == editModel.uid }) {
            graph.removeDeletedAppointmentView(at: deletedIndex)
        }
    }
    
    
    func didSelectDateInterval(_ dateInterval: DateInterval, person: RDPerson) {
        let eventCreationVC = RDAppointmentCreationVC(
            RDAppointment(uid: UUID().uuidString, title: nil, start: dateInterval.start,
                          end: dateInterval.start.addingTimeInterval(self.settings.duration), isWholeDay: false))
        
        eventCreationVC.didChangeAppointment = { [unowned self] in
            let newAppointment = RDAppointment(editModel: $0)
            self.appointmentsManager.updateEvents(for: person, changing: [newAppointment])
            let appointmentView = RDGraphAppointmentView(inside: self.graph)
            appointmentView.appointmentGraphDelegate = self
            appointmentView.navigationDelegate = self
            appointmentView.appointment = newAppointment
            appointmentView.person = person
            appointmentView.theme = .defaultTheme
        }
        
        let navigationVC = UINavigationController(rootViewController: eventCreationVC)
        self.present(navigationVC, animated: true)
    }
}
