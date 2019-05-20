
import UIKit


class RDGraphAppointmentView: RDGraphRect {
    struct Theme {
        let backgroundColor: UIColor
        let textAlignment: NSTextAlignment
        
        static let defaultTheme = Theme(
            backgroundColor: AppColors.labelOrderFillerColor.withAlphaComponent(0.1),
            textAlignment: .left)
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
    
    
    private var labelSideConstraints: NSLayoutConstraint?
    private let summaryLabel: UILabel = {
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
        label.numberOfLines = 0
        return label
    }()
    
    
    override func setupViews() {
        super.setupViews()
        backgroundColor = theme.backgroundColor
        addSubview(summaryLabel)
        addSubview(personNameLabel)
        
        let constraints = [
            personNameLabel.centerXAnchor.constraint(equalTo: summaryLabel.centerXAnchor),
            personNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            
            summaryLabel.topAnchor.constraint(equalTo: personNameLabel.bottomAnchor, constant: 5)
        ]
        
        addDetailedViewOnTap()
        updateLabelSideConstraint()
        NSLayoutConstraint.activate(constraints)
    }
    
    
    override func addSubviewToTheGraph(_ graph: RDTimeGraph) {
        graph.insertAppointment(self)
    }
    
    
    private func updateLabelSideConstraint() {
        labelSideConstraints?.isActive = false
        
        if theme.textAlignment == .left {
            labelSideConstraints = summaryLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10)
        } else {
            labelSideConstraints = summaryLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        }
        
        bringSubviewToFront(summaryLabel)
        summaryLabel.textAlignment = theme.textAlignment
        labelSideConstraints?.isActive = true
    }
    
    
    private func addDetailedViewOnTap() {
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(showDetailedView))
        addGestureRecognizer(tap)
    }
    
    
    @objc private func showDetailedView() {
        guard let _appointment = appointment else { return }
        let detailedVC = RDDetailedAppointmentVC(_appointment)
        detailedVC.didChangeAppointment = { [weak self] in
            if let _person = self?.person {
                self?.appointmentGraphDelegate?.didChangeAppointment($0, person: _person)
            }
        }
        navigationDelegate?.pushViewContoller(detailedVC)
    }
}
