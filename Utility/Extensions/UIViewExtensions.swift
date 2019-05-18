import UIKit

extension UIView {
    var recursiveSubviews: [UIView] {
        var subviews = self.subviews.compactMap { $0 }
        subviews.forEach { subviews.append(contentsOf: $0.recursiveSubviews) }
        return subviews
    }
    
    
    func setHidden(_ blocked: Bool, animated: Bool = true) {
        if !blocked {
            isHidden = false
        }
        
        UIView.animate(withDuration: animated ? 0.3 : 0, animations: {
            self.alpha = blocked ? 0 : 1
        }) { _ in
            self.isHidden = blocked
        }
    }
    
    func rotate(withDuration: TimeInterval, clockwise: Bool) {
        UIView.animate(withDuration: withDuration) {
            self.transform = self.transform.rotated(by: clockwise ? CGFloat.pi : -(CGFloat.pi * 0.999))
        }
    }
    
    
    static func animateButtonClick(_ views: [UIView]) {
        UIView.animate(withDuration: 0.2, animations: {
            let transform = CGAffineTransform(scaleX: 0.975, y: 0.96)
            views.forEach { $0.transform = transform }
        }) { success in
            UIView.animate(withDuration: 0.2) {
                views.forEach { $0.transform = CGAffineTransform.identity }
            }
        }
    }
    
    func opacityAnimation() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0.5
        }) { success in
            UIView.animate(withDuration: 0.2) {
                self.alpha = 1
            }
        }
    }
    
    
    final func topSafeAnchorIOS11(_ vc: UIViewController) -> NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.topAnchor
        } else {
            return vc.topLayoutGuide.bottomAnchor
        }
    }
    
    final func bottomSafeAnchorIOS11(_ vc: UIViewController) -> NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.bottomAnchor
        } else {
            return vc.bottomLayoutGuide.topAnchor
        }
    }
    
    
    final var leadingA: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.leadingAnchor
        } else {
            return leadingAnchor
        }
    }
    
    
    final var trailingA: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.trailingAnchor
        } else {
            return trailingAnchor
        }
    }
    
    
    var safeAreaBottomInset: CGFloat {
        if #available(iOS 11, *) {
            return safeAreaInsets.bottom
        } else {
            return 0
        }
    }
    
    
    final func copySuperviewSizeConstraints(_ superView: UIView, in vc: UIViewController? = nil) {
        if let _vc = vc {
            topAnchor.constraint(equalTo: superView.topSafeAnchorIOS11(_vc)).isActive = true
            bottomAnchor.constraint(equalTo: superView.bottomSafeAnchorIOS11(_vc)).isActive = true
        } else {
            topAnchor.constraint(equalTo: superView.topAnchor).isActive = true
            bottomAnchor.constraint(equalTo: superView.bottomAnchor).isActive = true
            centerXAnchor.constraint(equalTo: superView.centerXAnchor).isActive = true
            centerYAnchor.constraint(equalTo: superView.centerYAnchor).isActive = true
        }
        
        trailingAnchor.constraint(equalTo: superView.trailingA).isActive = true
        leadingAnchor.constraint(equalTo: superView.leadingA).isActive = true
    }
    
    static func separatorNoConstraints(
        _ parent: UIView, color: UIColor, _ height: NSLayoutDimension,
        width: CGFloat = 1, multiplier: CGFloat = 1) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = width * 0.1
        view.layer.borderColor = color.cgColor
        view.backgroundColor = color
        parent.addSubview(view)
        
        view.widthAnchor.constraint(equalToConstant: width).isActive = true
        view.heightAnchor.constraint(equalTo: height, multiplier: multiplier).isActive = true
        return view
    }
    
    
    static func separator(_ parent: UIView, color: UIColor, _ height: NSLayoutDimension,
                          _ inset: CGFloat, width: CGFloat = 1, multiplier: CGFloat = 1) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = width * 0.1
        view.layer.borderColor = color.cgColor
        view.backgroundColor = color
        parent.addSubview(view)
        
        view.centerYAnchor.constraint(equalTo: parent.centerYAnchor, constant: inset).isActive = true
        view.widthAnchor.constraint(equalToConstant: width).isActive = true
        view.heightAnchor.constraint(equalTo: height, multiplier: multiplier).isActive = true
        return view
    }
    
    
    static func separator(_ parent: UIView, color: UIColor, _ height: CGFloat,
                          _ inset: CGFloat, width: CGFloat = 1) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = width * 0.1
        view.layer.borderColor = color.cgColor
        view.backgroundColor = color
        parent.addSubview(view)
        
        view.centerYAnchor.constraint(equalTo: parent.centerYAnchor, constant: inset).isActive = true
        view.widthAnchor.constraint(equalToConstant: width).isActive = true
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
        return view
    }
}


protocol HighlightableView: class {
    var highlightAnimationRunning: Bool { set get }
    func runSelectColorAnimation(_ color: UIColor)
    func changeColorOnUnhighlight(_ color: UIColor)
}

extension HighlightableView where Self: UIView {
    func runSelectColorAnimation(_ color: UIColor = AppColors.cellSelectionColor) {
        if !highlightAnimationRunning {
            UIView.animate(withDuration: 0.2, animations: {
                self.backgroundColor = color
            }) { _ in
                UIView.animate(withDuration: 0.2) {
                    self.backgroundColor = AppColors.incomingMessageColor
                }
            }
        }
    }
    
    
    func changeColorOnUnhighlight(_ previousColor: UIColor = AppColors.cellSelectionColor) {
        highlightAnimationRunning = true
        backgroundColor = previousColor
        UIView.animate(withDuration: 0.2, animations: {
            self.backgroundColor = AppColors.incomingMessageColor
        }) { _ in
            self.highlightAnimationRunning = false
        }
    }
}
