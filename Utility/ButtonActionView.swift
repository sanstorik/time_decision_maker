
import UIKit


class ButtonActionView: UIView, HighlightableView {
    enum ButtonType {
        case list, action, valuePicker
    }
    
    var highlightAnimationRunning = false
    let label: UILabel = {
        let label = UILabel.defaultInit()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = UIColor.white
        return label
    }()
    
    
    let valueLabel: UILabel = {
        let label = UILabel.defaultInit()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = UIColor.lightGray
        return label
    }()
    
    
    private let arrow: UIImageView = {
        let arrow = UIImageView(image: UIImage(named: "right_arrow")?.withRenderingMode(.alwaysTemplate))
        arrow.tintColor = UIColor.lightGray
        arrow.contentMode = .scaleAspectFit
        arrow.translatesAutoresizingMaskIntoConstraints = false
        
        return arrow
    }()
    
    
    private let offset: CGFloat
    private let iconMultiplier: CGFloat
    private var buttonConstraints = [ButtonType: [NSLayoutConstraint]]()
    
    
    private var previousType: ButtonType?
    var type: ButtonType? {
        didSet {
            if let _type = type {
                updateButtonTypeUI(_type)
            }
        }
    }
    
    init(offset: CGFloat, iconMultiplier: CGFloat = 0.8) {
        self.offset = offset
        self.iconMultiplier = iconMultiplier
        super.init(frame: CGRect.zero)
        setupViews()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        self.offset = 0
        self.iconMultiplier = 0.8
        self.type = .action
        super.init(coder: aDecoder)
        setupViews()
    }
    
    
    func addTapClick(target: Any, action: Selector) {
        let tap = UITapGestureRecognizer()
        tap.addTarget(target, action: action)
        isUserInteractionEnabled = true
        addGestureRecognizer(tap)
    }
    
    
    private func setupViews() {
        addSubview(label)
        addSubview(arrow)
        addSubview(valueLabel)
        
        buttonConstraints[.list] = listTypeConstraints()
        buttonConstraints[.action] = [
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.centerXAnchor.constraint(equalTo: centerXAnchor)
        ]
        
        buttonConstraints[.valuePicker] = listTypeConstraints() + [
            valueLabel.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: arrow.leadingAnchor, constant: -offset * 0.2)
        ]
        
        previousType = .valuePicker
        NSLayoutConstraint.activate(buttonConstraints[.valuePicker]!)
    }
    
    
    private func updateButtonTypeUI(_ type: ButtonType) {
        if let _previousType = previousType {
            if _previousType == type { return }
            
            NSLayoutConstraint.deactivate(buttonConstraints[_previousType]!)
        }
        
        self.arrow.isHidden = type == .action
        self.valueLabel.isHidden = type == .action
        
        NSLayoutConstraint.activate(buttonConstraints[type]!)
        previousType = type
        setNeedsLayout()
    }
    
    
    private func listTypeConstraints() -> [NSLayoutConstraint] {
        return [
            label.leadingAnchor.constraint(equalTo: leadingA, constant: offset),
            label.trailingAnchor.constraint(equalTo: arrow.leadingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            arrow.trailingAnchor.constraint(equalTo: trailingA, constant: -offset),
            arrow.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 1),
            arrow.heightAnchor.constraint(equalTo: heightAnchor, multiplier: iconMultiplier),
            arrow.widthAnchor.constraint(equalTo: heightAnchor, multiplier: iconMultiplier)
        ]
    }
}

