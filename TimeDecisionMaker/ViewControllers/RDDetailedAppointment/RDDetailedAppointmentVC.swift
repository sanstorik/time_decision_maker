

import UIKit


class RDDetailedAppointmentVC: RDDynamicCellTableViewVC {
    private let appointment: RDAppointment
    private(set) var editModel: RDAppointmentEditModel
    var isUpdatingSession: Bool { return true }
    var didChangeAppointment: ((RDAppointmentEditModel) -> Void)?
    var didDeleteAppointment: ((RDAppointmentEditModel) -> Void)?
    
    override var navigationBarTitle: String? {
        return appointment.title
    }
    
    
    init(_ appointment: RDAppointment, readOnly: Bool = false) {
        self.appointment = appointment
        self.editModel = RDAppointmentEditModel(appointment: appointment)
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let firstSection = [
            RDTextFieldData(placeholder: "Title", save: { [unowned self] in
                self.titleDidChange($0)
            }) { [unowned self] in self.editModel.title },
            RDTextFieldData(placeholder: "Location", save: { _ in }) { nil }
        ]
        
        let secondSection = [
            RDBooleanData(title: "All-day", save: { [unowned self] in
                self.editModel.isWholeDay = $0
                self.reloadDateCell()
            }) { [unowned self] in self.editModel.isWholeDay },
            createStartDateData(),
            createEndDateData(),
            RDButtonData(type: .valuePicker(title: "Repeat", value: { "Never" })) { },
            RDButtonData(type: .valuePicker(title: "Travel time", value: { "None" })) { },
        ]
        
        let thirdSection = [
            RDButtonData(type: .valuePicker(title: "Calendar", value: { "None" })) { },
            RDButtonData(type: .valuePicker(title: "Invitees", value: { "None" })) { }
        ]
        
        let fourthSection = [
            RDButtonData(type: .valuePicker(title: "Alert", value: { "None" })) { },
            RDButtonData(type: .valuePicker(title: "Show as", value: { "Busy" })) { }
        ]
        
        let fifthSection = [
            RDButtonData(type: .action(title: "Delete event")) { [unowned self] in
                self.editModel.isDeleted = true
                self.didDeleteAppointment?(self.editModel)
                self.navigationController?.popViewController(animated: true)
            }
        ]
        
        data = [
            firstSection, secondSection, thirdSection, fourthSection
        ]
        
        if isUpdatingSession {
            data.append(fifthSection)
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isUpdatingSession {
            didChangeAppointment?(editModel)
        }
    }
    
    
    open func titleDidChange(_ title: String?) {
        editModel.title = title
        if isUpdatingSession {
            navigationItem.title = title
        }
    }
    
    
    private func createStartDateData() -> RDDateLabelData {
        let data = RDDateLabelData(title: "Starts", isWholeDay: { [unowned self] in
            self.editModel.isWholeDay
        }) { [unowned self] in self.editModel.start }
        data.setDidSelect { [unowned self] in
            let pickerData = RDDatePickerData(
                minimumDate: { nil },
                maximumDate: { [unowned self] in self.editModel.end },
                isWholeDay: { [unowned self] in self.editModel.isWholeDay },
                save: { [unowned self] in
                    self.editModel.start = $0
                    
                    if let _indexPath = data.indexPath {
                        self.tableView.reloadRows(at: [_indexPath], with: .none)
                    }
                },
                retrieve: { [unowned self] in self.editModel.start})
            
            self.changePickerModeForDataLabel(isPresented: $0, at: $1, for: pickerData)
        }
        return data
    }
    
    
    private func createEndDateData() -> RDDateLabelData {
        let data = RDDateLabelData(title: "Ends", isWholeDay: { [unowned self] in
            self.editModel.isWholeDay
        }) { [unowned self] in self.editModel.end }
        data.setDidSelect { [unowned self] in
            let pickerData = RDDatePickerData(
                minimumDate: { [unowned self] in self.editModel.start },
                maximumDate: { nil },
                isWholeDay: { [unowned self] in self.editModel.isWholeDay },
                save: { [unowned self] in
                    self.editModel.end = $0
                    
                    if let _indexPath = data.indexPath {
                        self.tableView.reloadRows(at: [_indexPath], with: .none)
                    }
                },
                retrieve: { [unowned self] in self.editModel.end })
            
            self.changePickerModeForDataLabel(isPresented: $0, at: $1, for: pickerData)
        }
        return data
    }
}
