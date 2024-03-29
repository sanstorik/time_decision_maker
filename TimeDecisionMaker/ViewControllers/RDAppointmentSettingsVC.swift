
import UIKit

struct RDScheduledAppointmentSettings {
    var duration: TimeInterval
    var secondPerson: RDPerson?
    var date: Date
    
    init() {
        duration = 30 * 60
        secondPerson = nil
        date = Date()
    }
}


class RDAppointmentSettingsVC: RDDynamicCellTableViewVC {
    private let appointmentsManager = RDAppointmentsManager()
    private let currentPerson: RDPerson
    private var currentPersonData: PersonAppointments
    private var availablePersons = [PersonAppointments]()
    private var settings = RDScheduledAppointmentSettings()
    
    
    override var navigationBarTitle: String? {
        return "Appointment settings"
    }
    
    
    init(person: RDPerson, date: Date) {
        self.currentPerson = person
        self.settings.date = date
        self.currentPersonData =  (person, [])
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.availablePersons = []
        
        appointmentsManager.loadAllPersons().forEach {
            if self.currentPerson.appointmentsFilePath == $0.person.appointmentsFilePath {
                self.currentPersonData = $0
            } else {
                self.availablePersons.append($0)
            }
        }
        
        if settings.secondPerson == nil && availablePersons.count > 0 {
            settings.secondPerson = availablePersons[0].person
        }
        
        setupData()
        tableView.reloadData()
    }
    
    
    private func setupData() {
        let firstSection = [
            createDurationPicker()
        ]
        
        var secondSection = [RDCellData]()
        let persons = availablePersons.map { $0.0 }
        for (index, person) in persons.enumerated() {
            let data = RDOptionPickerData(optionID: person.appointmentsFilePath, title: person.name, isSelected: { [unowned self] uid in
                return self.settings.secondPerson?.appointmentsFilePath == person.appointmentsFilePath
            }) { [unowned self] uid, isSelected in
                if isSelected {
                    self.settings.secondPerson = persons.first { $0.appointmentsFilePath == uid }
                    self.reloadOptionPickerCells(except: IndexPath(row: index, section: 1))
                } else {
                    self.settings.secondPerson = nil
                }
            }
            
            secondSection.append(data)
        }
        
        let thirdSection = [
            RDButtonData(type: .action(title: "Set Appointment Time")) { [unowned self] in
                if let _selectedPerson = self.settings.secondPerson {
                    let firstData = self.availablePersons.first { $0.0.appointmentsFilePath == _selectedPerson.appointmentsFilePath }
                    
                    guard let _firstData = firstData else { return }
                    let timeGraph = RDAppointmentTimeGraph(personsData: [self.currentPersonData, _firstData], settings: self.settings)
                    self.navigationController?.pushViewController(timeGraph, animated: true)
                } else {
                    self.showAlert("Missing data", message: "A person must be selected")
                }
            }
        ]
        
        data = [
            firstSection, secondSection, thirdSection
        ]
    }
    
    
    private func createDurationPicker() -> RDTimeData {
        let data = RDTimeData(title: "Duration") { [unowned self] in self.settings.duration }
        data.setDidSelect {
            let pickerData = RDDatePickerData(
                minimumDate: { nil },
                maximumDate: { nil },
                isWholeDay: { false },
                save: { [unowned self] date in
                    let (hours, minutes) = date.retrieveHoursAndMinutes()
                    self.settings.duration = TimeInterval(hours * 3600 + minutes * 60)
                    if let _indexPath = data.indexPath {
                        self.tableView.reloadRows(at: [_indexPath], with: .none)
                    }
                },
                retrieve: { [unowned self] in
                    return Date.hoursMinutesFromTimeInterval(self.settings.duration)
            })
            
            pickerData.pickerMode = .time
            self.changePickerModeForDataLabel(isPresented: $0, at: $1, for: pickerData)
        }
        
        return data
    }
    
    
    private func reloadOptionPickerCells(except indexPath: IndexPath) {
        let cellsToReload = tableView.visibleCells.filter { $0 is RDOptionPickerCell }
        var indexPaths = [IndexPath]()
        
        cellsToReload.forEach {
            if let ip = tableView.indexPath(for: $0), ip != indexPath {
                indexPaths.append(ip)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
        tableView.reloadRows(at: indexPaths, with: .none)
    }
    
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as? UITableViewHeaderFooterView)?.textLabel?.textColor = .white
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 1 ? "Select a person, with whom you would like to have an appointment" : nil
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 60 : super.tableView(tableView, heightForHeaderInSection: section)
    }
}
