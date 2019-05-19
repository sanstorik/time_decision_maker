
import UIKit

protocol RDNavigation: class {
    func present(viewController: UIViewController)
    func pushViewContoller(_ viewController: UIViewController)
}

protocol RDAppointmentGraphDelegate: class {
    func didChangeAppointment(_ editModel: RDAppointmentEditModel, person: RDPerson)
}


class RDAppointmentTimeGraph: CommonVC, RDNavigation, RDAppointmentGraphDelegate {
    private let date: Date
    private let personsData: [PersonAppointments]
    private let appointmentsManager = RDAppointmentsManager()
    private var scrollView: UIScrollView!
    private var graph: RDTimeGraph!
    
    
    init(personsData: [PersonAppointments], date: Date) {
        self.date = date
        self.personsData = personsData
        super.init(nibName: nil, bundle: nil)
    }

    
    required init?(coder aDecoder: NSCoder) {
        self.personsData = []
        self.date = Date()
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar(title: date.readableDateString(), bgColor: AppColors.incomingMessageColor)
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
        
        graph = RDTimeGraph(date: date)
        scrollView.addSubview(graph)
        graph.translatesAutoresizingMaskIntoConstraints = false
        graph.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        graph.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        graph.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        graph.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        graph.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        graph.createHourLines(linkedTo: scrollView.bottomAnchor)
        
        self.personsData[0].appointments.forEach {
            let appointmentView = RDGraphAppointmentView(inside: graph)
            appointmentView.appointmentGraphDelegate = self
            appointmentView.navigationDelegate = self
            appointmentView.appointment = $0
            appointmentView.person = personsData[0].person
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
        
        if let updatedView = graph.innerAppointmentViews.first(where: { $0.appointment?.uid == editModel.uid }) {
            updatedView.appointment = updatedAppointment
        }
    }
}
