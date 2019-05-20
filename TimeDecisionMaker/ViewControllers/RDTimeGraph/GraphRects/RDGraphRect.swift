

import UIKit


class RDGraphRect: UIView {
    enum Mode {
        case left, right, full
    }
    
    private let leftSeparator: UIView = {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = AppColors.alertSheetDarkButtonColor.withAlphaComponent(0.5)
        return line
    }()
    
    var mode: Mode = .full {
        didSet {
            updateSideAnchor()
        }
    }
    
    weak var appointmentGraphDelegate: RDAppointmentGraphDelegate?
    weak var navigationDelegate: RDNavigation?
    private(set) weak var graph: RDTimeGraph?
    private(set) var topConstraint: NSLayoutConstraint!
    private(set) var heightConstraint: NSLayoutConstraint!
    
    private var previousMode: Mode = .full
    private var modeConstraints = [Mode: [NSLayoutConstraint]]()
    private var rectWidthAnchor: NSLayoutConstraint?
    private var sideAnchor: NSLayoutConstraint?
    
    
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
            topConstraint!,
            heightConstraint!,
            
            leftSeparator.leadingAnchor.constraint(equalTo: leadingAnchor),
            leftSeparator.heightAnchor.constraint(equalTo: heightAnchor),
            leftSeparator.topAnchor.constraint(equalTo: topAnchor),
            leftSeparator.widthAnchor.constraint(equalToConstant: 1)
        ]
        
        modeConstraints[.left] = [
            leadingAnchor.constraint(equalTo: _graph.leadingAnchor, constant: _graph.hourlineLeadingOffset),
            widthAnchor.constraint(equalTo: _graph.widthAnchor, multiplier: 0.5,
                                   constant: -(_graph.hourlineLeadingOffset + 15) / 2),
        ]
        
        modeConstraints[.right] = [
            trailingAnchor.constraint(equalTo: _graph.trailingAnchor, constant: -15),
            widthAnchor.constraint(equalTo: _graph.widthAnchor, multiplier: 0.5,
                                   constant: -(_graph.hourlineLeadingOffset + 15) / 2),
        ]
        
        modeConstraints[.full] = [
            leadingAnchor.constraint(equalTo: _graph.leadingAnchor, constant: _graph.hourlineLeadingOffset),
            trailingAnchor.constraint(equalTo: _graph.trailingAnchor, constant: -15)
        ]
        
        previousMode = .full
        NSLayoutConstraint.activate(modeConstraints[.full]!)
        NSLayoutConstraint.activate(constraints)
    }
    
    
    open func addSubviewToTheGraph(_ graph: RDTimeGraph) { }
    
    
    private func updateSideAnchor() {
        if previousMode != mode {
            modeConstraints[previousMode]?.forEach { $0.isActive = false }
            modeConstraints[mode]?.forEach { $0.isActive = true }
            previousMode = mode
            setNeedsLayout()
        }
    }
}

