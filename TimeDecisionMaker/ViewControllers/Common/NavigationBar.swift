
import UIKit

protocol NavigationBar {
    func setupNavigationBar(title: String?, withImage imageView: UIView?)
}

extension NavigationBar where Self: UIViewController {
    func setupNavigationBar(title: String? = nil, withImage imageView: UIView? = nil) {
        navigationBar(title: title ?? "", bgColor: UIColor.black, textColor: UIColor.white, hideBackButtonTitle: true)
        
        navigationItem.titleView = imageView
    }
    
    
    func animateTitleColor(_ color: UIColor, duration: Double = 1) {
        UIView.animate(withDuration: duration) { [unowned self] () -> Void in
            self.navigationController?.navigationBar.titleTextAttributes =
                [NSAttributedString.Key.foregroundColor: color,
                 NSAttributedString.Key.font: UIFont.systemFont(ofSize: 19)]
        }
    }
    
    
    func setupNavigationBar(title: String, bgColor: UIColor, textColor: UIColor = UIColor.white,
                            hideBackButtonTitle: Bool = true) {
        navigationBar(title: title, bgColor: bgColor, textColor: textColor, hideBackButtonTitle: hideBackButtonTitle)
    }
    
    
    fileprivate func navigationBar(title: String, bgColor: UIColor, textColor: UIColor, hideBackButtonTitle: Bool) {
        navigationItem.title = title
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: textColor,
             NSAttributedString.Key.font: UIFont.systemFont(ofSize: 19)]
        
        navigationController?.navigationBar.barTintColor = bgColor
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.isOpaque = true
        navigationController?.navigationBar.isTranslucent = false

        if hideBackButtonTitle {
            self.navigationController?.navigationBar.topItem?.backBarButtonItem =
                UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        } else {
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = nil
        }
        
        setNeedsStatusBarAppearanceUpdate()
    }
}

extension CommonVC: NavigationBar { }

