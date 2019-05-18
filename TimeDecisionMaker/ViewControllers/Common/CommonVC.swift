import UIKit
import QuickLook

typealias KeyboardEvent = (_: NSNotification) -> Void
/* Keyboard observer for pushing view up */



protocol PresenterDelegate: class {
    func presentVC(_ vc: UIViewController)
    func dismissVC(_ completion: @escaping () -> Void)
}

extension PresenterDelegate where Self: UIViewController {
    func presentVC(_ vc: UIViewController) {
        present(vc, animated: true)
    }
    
    
    func dismissVC(_ completion: @escaping () -> ()) {
        dismiss(animated: true, completion: completion)
    }
}


extension CommonVC {
    @discardableResult
    final func registerDismissingKeyboardOnTap() -> UITapGestureRecognizer {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        return tap
    }
    
    
    final func registerKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow),
                                               name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        keyboardWillShowFor(notification, withSize: notification.endFrameKeyboardSize)
    }
    
    
    @objc private func keyboardWillHide(_ notification: NSNotification) {
        keyboardWillHideFor(notification, withSize: notification.endFrameKeyboardSize)
    }
    
    
    @objc private func keyboardDidShow(_ notification: NSNotification) {
        keyboardDidShowFor(notification, withSize: notification.endFrameKeyboardSize)
    }
    
    
    @objc open func keyboardWillShowFor(_ notification: NSNotification, withSize size: CGRect) { }
    
    @objc open func keyboardWillHideFor(_ notification: NSNotification, withSize size: CGRect) { }
    
    @objc open func keyboardDidShowFor(_ notification: NSNotification, withSize size: CGRect) { }
    
    
    @objc open func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension NSNotification {
    var endFrameKeyboardSize: CGRect {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? CGRect.zero
    }
    
    var beginFrameKeyboardSize: CGRect {
        return (userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue ?? CGRect.zero
    }
}



protocol ViewHolder: class {
    var view: UIView! { get }
}


extension UIViewController: ViewHolder { }


protocol SettableBackground: class {
    func setupBackground()
    func setupBackground(_ color: UIColor)
    func setupBackground(_ image: UIImage)
}

extension SettableBackground where Self: ViewHolder {
    func setupBackground() {
        setupBackground(UIImage(named: "bg_app")!)
    }
    
    
    func setupBackground(_ color: UIColor) {
        view.backgroundColor = color
    }
    
    
    func setupBackground(_ image: UIImage) {
        let iv = UIImageView(image: image)
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleToFill
        view.addSubview(iv)
        
        iv.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        iv.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        iv.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        iv.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        view.backgroundColor = UIColor.clear
    }
}

extension UITableView: ViewHolder, SettableBackground {
    var view: UIView! { return self }
}


class CommonVC: UIViewController, SettableBackground {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override var prefersStatusBarHidden: Bool { return false }
}

extension CommonVC {
    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
}


extension UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        if topViewController is QLPreviewController { return .lightContent }
        return topViewController?.preferredStatusBarStyle ?? super.preferredStatusBarStyle
    }
}

