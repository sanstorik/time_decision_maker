
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
    
    
    private let addIV: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "add")?.withRenderingMode(.alwaysTemplate)
        iv.tintColor = AppColors.alertSheetDarkButtonColor
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    

    override func setupViews() {
        super.setupViews()
        backgroundColor = AppColors.freeIntervalDateColor
        addSubview(summaryLabel)
        addSubview(addIV)
        
        let constraints = [
            summaryLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            summaryLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            
            addIV.centerXAnchor.constraint(equalTo: centerXAnchor),
            addIV.centerYAnchor.constraint(equalTo: centerYAnchor),
            addIV.widthAnchor.constraint(lessThanOrEqualTo: heightAnchor, multiplier: 0.5),
            addIV.widthAnchor.constraint(lessThanOrEqualToConstant: 40),
            
            addIV.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor, multiplier: 0.5),
            addIV.heightAnchor.constraint(lessThanOrEqualToConstant: 40)
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
