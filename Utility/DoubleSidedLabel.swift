
import UIKit


class DoubleSidedLabel: UILabel {
    private var hidingAnimationRunning = false
    private let hidingAnimationDuration = 0.4
    
    let rightSideLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        return titleLabel
    }()
    
    
    required init(frame: CGRect, titleLabelOffset: CGFloat) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        insertSubview(rightSideLabel, aboveSubview: self)
        rightSideLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: titleLabelOffset).isActive = true
        rightSideLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    private func updateLabelView() {
        if !isTextEmpty() && (rightSideLabel.isHidden || hidingAnimationRunning) {
            showLabelAnimated()
        } else if isTextEmpty() && !rightSideLabel.isHidden {
            hideLabelAnimated()
        }
    }
    
    
    private func showLabelAnimated() {
        rightSideLabel.layer.removeAllAnimations()
        hidingAnimationRunning = false
        rightSideLabel.isHidden = false
        
        UIView.animate(withDuration: hidingAnimationDuration) {
            self.rightSideLabel.alpha = 1
        }
    }
    
    
    private func hideLabelAnimated() {
        rightSideLabel.layer.removeAllAnimations()
        hidingAnimationRunning = true
        
        UIView.animate(
            withDuration: hidingAnimationDuration,
            animations: {
                self.rightSideLabel.alpha = 0
        }) {
            self.hidingAnimationRunning = false
            self.rightSideLabel.isHidden = $0
        }
    }
    
    
    private func isTextEmpty() -> Bool {
        return text?.isEmpty ?? true
    }
}

