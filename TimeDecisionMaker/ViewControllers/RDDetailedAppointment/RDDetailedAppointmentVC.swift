

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
        let customCells: [RDTemplateCell.Type] = [RDTextFieldCell.self, RDBooleanCell.self]
        
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
            RDTextFieldData(placeholder: "Location", save: { _ in }) { nil }
        ]
        
        data = [
            firstSection, secondSection
        ]
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        didChangeAppointment?(editModel)
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
        
        cell.data = dataForRow
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.deviceHeight * 0.06
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
}
