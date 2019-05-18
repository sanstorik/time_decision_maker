import UIKit

extension CGRect {
    var deviceHeight: CGFloat {
        return height > width ? height : width
    }
    
    var deviceWidth: CGFloat {
        return height > width ? width : height
    }
}


extension UIDevice {
    enum ScreenType: String {
        case iPhones_4_4S = "iPhone 4 or iPhone 4S"
        case iPhones_5_5s_5c_SE = "iPhone 5, iPhone 5s, iPhone 5c or iPhone SE"
        case iPhones_6_6s_7_8 = "iPhone 6, iPhone 6S, iPhone 7 or iPhone 8"
        case iPhones_6Plus_6sPlus_7Plus_8Plus = "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus"
        case iPhones_X_XS = "iPhone X or iPhone XS"
        case iPhone_XR = "iPhone XR"
        case iPhone_XSMax = "iPhone XS Max"
        case unknown
    }
    
    static var screenType: ScreenType {
        switch UIScreen.main.nativeBounds.height {
        case 960:
            return .iPhones_4_4S
        case 1136:
            return .iPhones_5_5s_5c_SE
        case 1334:
            return .iPhones_6_6s_7_8
        case 1792:
            return .iPhone_XR
        case 1920, 2208:
            return .iPhones_6Plus_6sPlus_7Plus_8Plus
        case 2436:
            return .iPhones_X_XS
        case 2688:
            return .iPhone_XSMax
        default:
            return .unknown
        }
    }
    
    static var isPad: Bool {
        return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
    }
    
    
    static var isPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone
    }
    
    
    static var isLandscape: Bool {
        return UIDevice.current.orientation == .landscapeLeft
            || UIDevice.current.orientation == .landscapeRight
            || UIScreen.main.bounds.width > UIScreen.main.bounds.height
    }
    
    
    static var isPortait: Bool {
        return UIDevice.current.orientation == .portrait
            || UIDevice.current.orientation == .portraitUpsideDown
            || UIScreen.main.bounds.height > UIScreen.main.bounds.width
    }
    
    
    static var deviceUUID: UUID {
        return UIDevice.current.identifierForVendor!
    }
}


extension Float {
    func with(min: Float, max: Float) -> CGFloat {
        if self < min { return CGFloat(min) }
        if self > max { return CGFloat(max) }
        return CGFloat(self)
    }
}


extension CGFloat {
    func with(min: CGFloat, max: CGFloat) -> CGFloat {
        if self < min { return min }
        if self > max { return max }
        return self
    }
}

protocol DevicesSizeProtocol {
    var value: CGFloat { get }
}

extension DevicesSizeProtocol where Self: Numeric {
    func ifIpad(_ val: Self) -> Self {
        return UIDevice.isPad ? val : self
    }
    
    
    func ifIpad(_ val: CGFloat) -> CGFloat {
        return UIDevice.isPad ? val : value
    }
    
    
    func ifIphone5(_ val: Self) -> Self {
        return UIDevice.screenType == .iPhones_5_5s_5c_SE ? val : self
    }
    
    
    func ifIphone5(_ val: CGFloat) -> CGFloat {
        return UIDevice.screenType == .iPhones_5_5s_5c_SE ? val : value
    }
}

extension Int: DevicesSizeProtocol {
    var value: CGFloat { return CGFloat(self) }
}

extension Double: DevicesSizeProtocol {
    var value: CGFloat { return CGFloat(self) }
}

extension Float: DevicesSizeProtocol {
    var value: CGFloat { return CGFloat(self) }
}

extension CGFloat: DevicesSizeProtocol {
    var value: CGFloat { return self }
}

