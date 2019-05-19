
import UIKit


class RDGraphAppointmentView: UIView {
    var person: RDPerson?
    var appointment: RDAppointment? {
        didSet {
            if let _appointment = appointment {
                graph?.placeAppointmentView(self)
                summaryLabel.text = _appointment.title
            }
        }
    }
    
    
    private let summaryLabel: UILabel = {
        let label = UILabel.defaultInit()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    
    private let leftSeparator: UIView = {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = AppColors.alertSheetDarkButtonColor.withAlphaComponent(0.5)
        return line
    }()
    
    
    weak var appointmentGraphDelegate: RDAppointmentGraphDelegate?
    weak var navigationDelegate: RDNavigation?
    private weak var graph: RDTimeGraph?
    private(set) var topConstraint: NSLayoutConstraint!
    private(set) var heightConstraint: NSLayoutConstraint!
    
    
    init(inside graph: RDTimeGraph) {
        self.graph = graph
        super.init(frame: .zero)
        commonInit()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    private func commonInit() {
        backgroundColor = AppColors.labelOrderFillerColor.withAlphaComponent(0.1)
        translatesAutoresizingMaskIntoConstraints = false
        
        guard let _graph = graph else { return }
        addSubview(leftSeparator)
        addSubview(summaryLabel)
        
        _graph.insertAppointment(self)
        self.heightConstraint = heightAnchor.constraint(equalToConstant: 0)
        self.topConstraint = topAnchor.constraint(equalTo: _graph.topAnchor, constant: _graph.zeroHourStartingHeight)
        
        let constraints = [
            leadingAnchor.constraint(equalTo: _graph.leadingAnchor, constant: _graph.hourlineLeadingOffset),
            trailingAnchor.constraint(equalTo: _graph.trailingAnchor, constant: -15),
            topConstraint!,
            heightConstraint!,
            
            summaryLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            summaryLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            
            leftSeparator.leadingAnchor.constraint(equalTo: leadingAnchor),
            leftSeparator.heightAnchor.constraint(equalTo: heightAnchor),
            leftSeparator.topAnchor.constraint(equalTo: topAnchor),
            leftSeparator.widthAnchor.constraint(equalToConstant: 1)
        ]
        
        NSLayoutConstraint.activate(constraints)
        addDetailedViewOnTap()
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
