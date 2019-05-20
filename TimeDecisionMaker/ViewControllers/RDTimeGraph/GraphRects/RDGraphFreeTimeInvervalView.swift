
import UIKit


class RDGraphFreeIntervalView: RDGraphRect {
    var person: RDPerson?
    var dateInterval: DateInterval? {
        didSet {
            graph?.placeFreeIntervalView(self)
        }
    }

    private let summaryLabel: UILabel = {
        let label = UILabel.defaultInit()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    

    override func setupViews() {
        super.setupViews()
        backgroundColor = AppColors.freeIntervalDateColor
        addSubview(summaryLabel)
        
        let constraints = [
            summaryLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            summaryLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5)
        ]
        
        NSLayoutConstraint.activate(constraints)
        addDetailedViewOnTap()
    }
    
    
    override func addSubviewToTheGraph(_ graph: RDTimeGraph) {
        graph.insertFreeInterval(self)
    }
    
    
    private func addDetailedViewOnTap() {
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(showDetailedView))
        addGestureRecognizer(tap)
    }
    
    
    @objc private func showDetailedView() {
        guard let _dateInterval = dateInterval, let _person = person else { return }
        appointmentGraphDelegate?.didSelectDateInterval(_dateInterval, person: _person)
    }
}
