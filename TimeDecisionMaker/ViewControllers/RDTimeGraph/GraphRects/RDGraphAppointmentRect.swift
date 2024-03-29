
import UIKit


class RDGraphAppointmentView: RDGraphRect {
    struct Theme {
        let backgroundColor: UIColor
        let mode: Mode
        
        static let defaultTheme = Theme(
            backgroundColor: AppColors.labelOrderFillerColor.withAlphaComponent(0.1),
            mode: .full)
    }
    
    var theme: Theme = .defaultTheme {
        didSet {
            backgroundColor = theme.backgroundColor
            updateLabelSideConstraint()
        }
    }
    
    var person: RDPerson? {
        didSet {
            personNameLabel.text = person?.name
        }
    }
    
    var appointment: RDAppointment? {
        didSet {
            if let _appointment = appointment {
                graph?.placeAppointmentView(self)
                summaryLabel.text = _appointment.title
            }
        }
    }
    
    
    private var labelSideConstraints = [NSLayoutConstraint]()
    let summaryLabel: UILabel = {
        let label = UILabel.defaultInit()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    private let personNameLabel: UILabel = {
        let label = UILabel.defaultInit()
        label.textColor = AppColors.messengerUsernameColor
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 1
        return label
    }()
    
    
    override func setupViews() {
        super.setupViews()
        backgroundColor = theme.backgroundColor
        addSubview(summaryLabel)
        addSubview(personNameLabel)
        
        let constraints = [
            personNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            personNameLabel.widthAnchor.constraint(equalTo: widthAnchor, constant: -10),
            
            summaryLabel.topAnchor.constraint(equalTo: personNameLabel.bottomAnchor, constant: 5),
            summaryLabel.widthAnchor.constraint(equalTo: widthAnchor, constant: -10)
        ]
        
        addDetailedViewOnTap()
        updateLabelSideConstraint()
        NSLayoutConstraint.activate(constraints)
    }
    
    
    override func addSubviewToTheGraph(_ graph: RDTimeGraph) {
        graph.insertAppointment(self)
    }
    
    
    private func updateLabelSideConstraint() {
        self.mode = theme.mode
        labelSideConstraints.forEach { $0.isActive = false }
        
        switch theme.mode {
        case .right:
            labelSideConstraints = [
                summaryLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                personNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
            ]
        default:
            labelSideConstraints = [
                summaryLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                personNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10)
            ]
        }
        
        personNameLabel.textAlignment = theme.mode == .right ? .right : .left
        summaryLabel.textAlignment = theme.mode == .right ? .right : .left
        labelSideConstraints.forEach { $0.isActive = true }
    }
    
    
    private func addDetailedViewOnTap() {
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(showDetailedView))
        addGestureRecognizer(tap)
    }
    
    
    @objc private func showDetailedView() {
        guard let _appointment = appointment else { return }
        let detailedVC = RDDetailedAppointmentVC(_appointment)
        detailedVC.didDeleteAppointment = { [weak self] in
            if let _person = self?.person {
                self?.appointmentGraphDelegate?.didDeleteAppointment($0, person: _person)
            }
        }
        
        detailedVC.didChangeAppointment = { [weak self] in
            if let _person = self?.person {
                self?.appointmentGraphDelegate?.didChangeAppointment($0, person: _person)
            }
        }
        navigationDelegate?.pushViewContoller(detailedVC)
    }
}
