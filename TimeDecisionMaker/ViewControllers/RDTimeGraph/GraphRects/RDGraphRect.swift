

import UIKit


class RDGraphRect: UIView {
    private let leftSeparator: UIView = {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = AppColors.alertSheetDarkButtonColor.withAlphaComponent(0.5)
        return line
    }()
    
    
    weak var appointmentGraphDelegate: RDAppointmentGraphDelegate?
    weak var navigationDelegate: RDNavigation?
    private(set) weak var graph: RDTimeGraph?
    private(set) var topConstraint: NSLayoutConstraint!
    private(set) var heightConstraint: NSLayoutConstraint!
    
    
    init(inside graph: RDTimeGraph) {
        self.graph = graph
        super.init(frame: .zero)
        setupViews()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    open func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false
        
        guard let _graph = graph else { return }
        addSubview(leftSeparator)
        addSubviewToTheGraph(_graph)
        self.heightConstraint = heightAnchor.constraint(equalToConstant: 0)
        self.topConstraint = topAnchor.constraint(equalTo: _graph.topAnchor, constant: _graph.zeroHourStartingHeight)
        
        let constraints = [
            leadingAnchor.constraint(equalTo: _graph.leadingAnchor, constant: _graph.hourlineLeadingOffset),
            trailingAnchor.constraint(equalTo: _graph.trailingAnchor, constant: -15),
            topConstraint!,
            heightConstraint!,
            
            leftSeparator.leadingAnchor.constraint(equalTo: leadingAnchor),
            leftSeparator.heightAnchor.constraint(equalTo: heightAnchor),
            leftSeparator.topAnchor.constraint(equalTo: topAnchor),
            leftSeparator.widthAnchor.constraint(equalToConstant: 1)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    
    open func addSubviewToTheGraph(_ graph: RDTimeGraph) { }
}

