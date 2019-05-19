

import UIKit


class RDDetailedAppointmentVC: CommonVC {
    private let appointment: RDAppointment
    private var tableView: UITableView!
    private var data = [[RDCellData]]()
    private var editModel: RDAppointmentEditModel
    private var presentedPickerIndexPath: IndexPath?
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
        tableView = setupTableView(bottomAnchor: view.bottomSafeAnchorIOS11(self))
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
                self.showAlert("ERROR-404", message: "Feature is not implemented yet")
            }
        ]
        
        data = [
            firstSection, secondSection, thirdSection, fourthSection, fifthSection
        ]
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        didChangeAppointment?(editModel)
    }
    
    
    private func createStartDateData() -> RDDateLabelData {
        let data = RDDateLabelData(title: "Starts", isWholeDay: { [unowned self] in
            self.editModel.isWholeDay
        }) { [unowned self] in self.editModel.start }
        data.setDidSelect {
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
        data.setDidSelect {
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
    
    
    private func changePickerModeForDataLabel(isPresented: Bool, at indexPath: IndexPath, for data: RDDatePickerData) {
        let pickerIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
        
        if isPresented {
            forceHideOtherDatePickers(except: indexPath)
            self.data[indexPath.section].insert(data, at: pickerIndexPath.row)
            self.presentedPickerIndexPath = pickerIndexPath
            tableView.insertRows(at: [pickerIndexPath], with: .fade)
        } else {
            self.data[indexPath.section].remove(at: pickerIndexPath.row)
            self.presentedPickerIndexPath = nil
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
    
    
    private func reloadDateCell() {
        let cellsToReload = tableView.visibleCells.filter { $0 is RDDateLabelCell || $0 is RDDatePickerCell }
        let indexPaths = cellsToReload.compactMap { tableView.indexPath(for: $0) }
        tableView.reloadRows(at: indexPaths, with: .none)
    }
    
    
    private func updatedCellIndexPathIncludingPresentedDatePicker(_ indexPath: IndexPath) -> IndexPath {
        if let _pickerIndexPath = presentedPickerIndexPath, indexPath.section == _pickerIndexPath.section,
            indexPath.row >= _pickerIndexPath.row {
            return IndexPath(row: indexPath.row - 1, section: indexPath.section)
        } else {
            return indexPath
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
        
        dataForRow.indexPath = updatedCellIndexPathIncludingPresentedDatePicker(indexPath)
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
