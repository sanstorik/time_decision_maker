

import UIKit


class RDAppointmentCreationVC: RDDetailedAppointmentVC {
    override var navigationBarTitle: String? {
        return "New event"
    }
    
    override var isUpdatingSession: Bool { return false }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(save))
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    
    @objc private func cancel() {
        dismiss(animated: true)
    }
    
    
    override func titleDidChange(_ title: String?) {
        super.titleDidChange(title)
        navigationItem.rightBarButtonItem?.isEnabled = title != nil && !title!.isEmpty
    }
    
    
    @objc private func save() {
        didChangeAppointment?(self.editModel)
        dismiss(animated: true)
    }
}
