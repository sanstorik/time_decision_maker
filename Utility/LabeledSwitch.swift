

import UIKit


class LabeledSwitch: UIView, HighlightableView {
    var highlightAnimationRunning = false
    
    
    let label: UILabel = {
        let label = UILabel.defaultInit()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = AppColors.colorPrimaryText
        
        return label
    }()
    
    
    private let boolean: UISwitch = {
        let uiSwitch = UISwitch()
        uiSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        return uiSwitch
    }()
    
    
    private let booleanSwitchHolder: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    private let offset: CGFloat
    private let switchOffset: CGFloat
    var didChangeValue: ((Bool) -> ())?
    
    var isOn: Bool = false {
        didSet {
            boolean.isOn = isOn
        }
    }
    
    
    init(offset: CGFloat, switchOffsetFromRight: CGFloat = -40) {
        self.offset = offset
        self.switchOffset = switchOffsetFromRight
        super.init(frame: CGRect.zero)
        setupViews()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        offset = 0
        switchOffset = 0
        super.init(coder: aDecoder)
        setupViews()
    }
    
    
    private func setupViews() {
        addSubview(label)
        addSubview(booleanSwitchHolder)
        booleanSwitchHolder.addSubview(boolean)
        
        label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -switchOffset).isActive = true
        label.trailingAnchor.constraint(equalTo: booleanSwitchHolder.leadingAnchor, constant: -10).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        booleanSwitchHolder.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        booleanSwitchHolder.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                      constant: switchOffset * 0.7).isActive = true
        booleanSwitchHolder.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.2).isActive = true
        booleanSwitchHolder.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.8).isActive = true
        
        boolean.centerXAnchor.constraint(equalTo: booleanSwitchHolder.centerXAnchor).isActive = true
        boolean.centerYAnchor.constraint(equalTo: booleanSwitchHolder.centerYAnchor).isActive = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(switchManually))
        booleanSwitchHolder.addGestureRecognizer(tap)
        boolean.addTarget(self, action: #selector(didSwitch), for: .valueChanged)
    }
    
    
    @objc private func didSwitch() {
        self.didChangeValue?(boolean.isOn)
    }
    
    
    @objc private func switchManually() {
        let previousValue = boolean.isOn
        boolean.setOn(!previousValue, animated: true)
        self.didChangeValue?(!previousValue)
    }
}
