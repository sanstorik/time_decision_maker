

import UIKit


class LaunchVC: CommonVC {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground(AppColors.messengerBackgroundColor)
    }
}
