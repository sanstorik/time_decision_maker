
import UIKit


class ButtonActionView: UIView, HighlightableView {
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
    
    
    private var offset: CGFloat = 0
    private var iconMultiplier: CGFloat = 0.8
    
    init(offset: CGFloat, iconMultiplier: CGFloat = 0.8) {
        self.offset = offset
        self.iconMultiplier = iconMultiplier
        super.init(frame: CGRect.zero)
        setupViews()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    
    private func setupViews() {
        addSubview(label)
        addSubview(arrow)
        addSubview(valueLabel)
        
        label.leadingAnchor.constraint(equalTo: leadingA, constant: offset).isActive = true
        label.trailingAnchor.constraint(equalTo: arrow.leadingAnchor).isActive = true
        label.topAnchor.constraint(equalTo: topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        arrow.trailingAnchor.constraint(equalTo: trailingA, constant: -offset).isActive = true
        arrow.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        arrow.heightAnchor.constraint(equalTo: heightAnchor, multiplier: iconMultiplier).isActive = true
        arrow.widthAnchor.constraint(equalTo: heightAnchor, multiplier: iconMultiplier).isActive = true
        
        valueLabel.centerYAnchor.constraint(equalTo: arrow.centerYAnchor).isActive = true
        valueLabel.trailingAnchor.constraint(equalTo: arrow.leadingAnchor, constant: -offset).isActive = true
    }
}

