
import UIKit


class RDGraphHourLine: UIView {
    let hourLabel: UILabel = {
        let label = UILabel.defaultInit()
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .right
        return label
    }()
    
    
    private let line: UIView = {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = UIColor.lightGray
        return line
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    
    private func setupViews() {
        addSubview(hourLabel)
        addSubview(line)
        
        let constraints = [
            hourLabel.widthAnchor.constraint(equalToConstant: 40),
            hourLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            hourLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            line.leadingAnchor.constraint(equalTo: hourLabel.trailingAnchor, constant: 8),
            line.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            line.centerYAnchor.constraint(equalTo: centerYAnchor),
            line.heightAnchor.constraint(equalToConstant: 0.4)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}

