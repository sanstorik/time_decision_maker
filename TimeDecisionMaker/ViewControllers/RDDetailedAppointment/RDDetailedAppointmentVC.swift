

import UIKit


class RDDetailedAppointmentVC: CommonVC {
    private let appointment: RDAppointment
    private var tableView: UITableView!
    private var data = [[RDCellData]]()
    private var editModel: RDAppointmentEditModel
    var didChangeAppointment: ((RDAppointmentEditModel) -> Void)?
    
    
    init(_ appointment: RDAppointment) {
        self.appointment = appointment
        self.editModel = RDAppointmentEditModel(appointment: appointment)
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground(AppColors.messengerBackgroundColor)
        setupNavigationBar(title: appointment.title ?? "Appointment", bgColor: AppColors.incomingMessageColor)
        tableView = setupTableView()
        let customCells: [RDTemplateCell.Type] = [RDTextFieldCell.self, RDBooleanCell.self,
                                                  RDDateLabelCell.self, RDDatePickerCell.self,
                                                  RDButtonCell.self]
        
        customCells.forEach {
            tableView.register($0.self, forCellReuseIdentifier: $0.identifier)
        }
        
        let firstSection = [
            RDTextFieldData(placeholder: "Title", save: { [unowned self] in
                self.editModel.title = $0
                self.navigationItem.title = $0
            }) { [unowned self] in self.editModel.title },
            RDTextFieldData(placeholder: "Location", save: { _ in }) { nil }
        ]
        
        let secondSection = [
            RDBooleanData(title: "All-day", save: { [unowned self] in
                self.editModel.isWholeDay = $0 }) { [unowned self] in self.editModel.isWholeDay },
            createStartDateData(),
            createEndDateData(),
            RDButtonData(title: "Repeat",  value: "Never") { },
            RDButtonData(title: "Travel time", value: "None") { }
        ]
        
        let thirdSection = [
            RDButtonData(title: "Calendar", value: "Home") { },
            RDButtonData(title: "Invitees", value: "None") { }
        ]
        
        let fourthSection = [
            RDButtonData(title: "Alert", value: "None") { },
            RDButtonData(title: "Show as", value: "Busy") { }
        ]
        
        data = [
            firstSection, secondSection, thirdSection, fourthSection
        ]
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        didChangeAppointment?(editModel)
    }
    
    
    private func createStartDateData() -> RDDateLabelData {
        let data = RDDateLabelData(title: "Starts") { [unowned self] in self.editModel.start }
        data.setDidSelect {
            let pickerData = RDDatePickerData(
                minimumDate: nil,
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
        let data = RDDateLabelData(title: "Ends") { [unowned self] in self.editModel.end }
        data.setDidSelect {
            let pickerData = RDDatePickerData(
                minimumDate: self.editModel.start,
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
    
    
    private func changePickerModeForDataLabel(isPresented: Bool, at indexPath: IndexPath, for data: RDDatePickerData) {
        let pickerIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
        
        if isPresented {
            forceHideOtherDatePickers(except: indexPath)
            self.data[indexPath.section].insert(data, at: pickerIndexPath.row)
            tableView.insertRows(at: [pickerIndexPath], with: .fade)
        } else {
            self.data[indexPath.section].remove(at: pickerIndexPath.row)
            tableView.deleteRows(at: [pickerIndexPath], with: .fade)
        }
    }
    
    
    private func forceHideOtherDatePickers(except labelIndexPath: IndexPath) {
        for cell in tableView.visibleCells where cell is RDDateLabelCell {
            let dataCell = cell as! RDDateLabelCell
            if let cellIndexPath = tableView.indexPath(for: dataCell), cellIndexPath == labelIndexPath {
                continue
            }
            
            dataCell.forceHideDatePicker()
        }
    }
}


extension RDDetailedAppointmentVC: FullScreenTableViewHolder, UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataForRow = data[indexPath.section][indexPath.row]
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: dataForRow.identifier, for: indexPath) as? RDTemplateCell else {
                fatalError()
        }
        
        dataForRow.indexPath = indexPath
        cell.data = dataForRow
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.deviceHeight * data[indexPath.section][indexPath.row].rowHeightMultiplier
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? RDTemplateCell {
            cell.didSelect()
        }
    }
    
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? RDTemplateCell {
            cell.didUnhighlight()
        }
    }

    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 20 : 25
    }
}
