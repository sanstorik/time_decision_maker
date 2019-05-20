import UIKit


extension UILabel {
    class func defaultInit() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 14)
        
        return label
    }
}


class CorneredButton: UIButton {
    private var radius: CGFloat
    private var shadow: Bool
    
    
    init(shadow: Bool, radius: CGFloat = 0.5) {
        self.radius = radius
        self.shadow = shadow
        super.init(frame: CGRect.zero)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.size.width * radius
        
        if shadow {
            layer.shadowColor = UIColor.darkGray.cgColor
            layer.shadowOpacity = 0.6
            layer.shadowOffset = CGSize(width: 0, height: 3)
            layer.shadowRadius = 5
        }
    }
}


class OffsetButton: UIButton {
    private var offset: CGFloat
    
    
    init(offset: CGFloat = 5) {
        self.offset = offset
        super.init(frame: CGRect.zero)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    override func backgroundRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.minX + offset,
                      y: bounds.minY + offset,
                      width: bounds.width - offset * 2,
                      height: bounds.height - offset * 2)
    }
}

class CorneredUIView: UIView {
    private var radius: CGFloat

    
    init(radius: CGFloat = 0.5) {
        self.radius = radius
        super.init(frame: CGRect.zero)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.size.width * radius
    }
}




extension NSLayoutConstraint {
    func lowerPriority() {
        priority = UILayoutPriority(rawValue: 999)
        isActive = true
    }
}


extension UIColor {
    convenience init<T: SignedInteger>(red: T, green: T, blue: T, alpha: CGFloat = 1) {
        self.init(red: CGFloat(red) / 255,
                  green: CGFloat(green) / 255,
                  blue: CGFloat(blue) / 255, alpha: alpha)
    }
    
    
    func defaultColorIfNotVisibile() -> UIColor {
        if CIColor(color: self).alpha == 0 {
            return UIColor.black
        }
        
        return self
    }
    
    
    static func fromAPI(intValue: Int32) -> UIColor {
        let blue = intValue & 0xFF
        let green = (intValue >> 8) & 0xFF
        let red = (intValue >> 16) & 0xFF
        let alpha = (intValue >> 24) & 0xFF
        
        return UIColor(red: red, green: green, blue: blue, alpha: (CGFloat(alpha) / 255))
    }
    
    
    func toAPIColor() -> Int32 {
        let ciColor = CIColor(color: self)
        let alpha = toInt(ciColor.alpha)
        let red = toInt(ciColor.red)
        let green = toInt(ciColor.green)
        let blue = toInt(ciColor.blue)
        
        return alpha << 24 | red << 16 | green << 8 | blue
    }
    
    
    fileprivate func toInt(_ value: CGFloat) -> Int32 {
        return Int32(value * 255)
    }
}




struct AppColors {
    static let colorPrimary: UIColor = UIColor(red: 0.42, green: 0.23, blue: 0.55, alpha: 1.00)
    static let colorPrimaryDark: UIColor = UIColor(red: 0.27, green: 0.14, blue: 0.35, alpha: 1.00)
    static let colorPrimaryLight: UIColor = UIColor(red: 0.62, green: 0.50, blue: 0.71, alpha: 1.00)
    static let colorAccent: UIColor = UIColor(red: 1.00, green: 0.25, blue: 0.51, alpha: 1.00)
    static let colorPrimaryText: UIColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.00)
    static let colorSecondaryText: UIColor = UIColor(red: 0.46, green: 0.46, blue: 0.46, alpha: 1.00)
    static let colorIcons: UIColor = UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.00)
    static let colorDivider: UIColor = UIColor(red: 0.74, green: 0.74, blue: 0.74, alpha: 1.00)
    static let colorNavigationDrawerIcon: UIColor = UIColor(red: 0.46, green: 0.46, blue: 0.46, alpha: 1.00)
    
    static var colorNavigationBarText: UIColor = UIColor.black
    
    static let backgroundColor: UIColor = UIColor(red: 229, green: 230, blue: 238)
    static var headerColor = UIColor(red: 67, green: 37, blue: 89)
    static var labelOrderFillerColor = UIColor(red: 248, green: 247, blue: 249)
    static var labelPersonFillerColor = UIColor(red: 231, green: 226, blue: 235)
    
    static var separatorDarkColor = UIColor(red: 123, green: 134, blue: 143)
    static var separatorLightColor = UIColor(red: 199, green: 206, blue: 211)
    static var grayed = UIColor(red: 168, green: 161, blue: 169)
    
    static var grayClick = UIColor(red: 235, green: 235, blue: 235)
    static let dashboardTabColor = UIColor(red: 0.62, green: 0.50, blue: 0.71, alpha: 0.6)
    
    static let defaultNavigationBarColor = UIColor(red: 0.969, green: 0.969, blue: 0.969, alpha: 1.0)
    
    // MESSENGER
    static let incomingMessageColor = UIColor(red: 34, green: 47, blue: 62)
    static let outgoingMessageColor = UIColor(red: 64, green: 107, blue: 149, alpha: 0.65)
    static let inputTextFieldColor = UIColor(red: 18, green: 28, blue: 36)
    static let messengerBackgroundColor = UIColor(red: 24, green: 34, blue: 43)
    static let messengerUsernameColor = UIColor(red: 192, green: 132, blue: 128)
    
    static let alertSheetDarkButtonColor = UIColor(red: 49, green: 164, blue: 236)
    static let cellSelectionColor = UIColor.black.withAlphaComponent(0.3)
    
    
    static let freeIntervalDateColor = UIColor(red: 155, green: 226, blue: 89).withAlphaComponent(0.2)
    static let lightBlueColor = UIColor(red: 158, green: 234, blue: 255).withAlphaComponent(0.2)
}
