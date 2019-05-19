
import UIKit

struct RDBookingSettings {
    var duration: TimeInterval
    var secondPerson: RDPerson?
    
    init() {
        duration = 30 * 60
        secondPerson = nil
    }
}


class RDAppointmentSettingsVC: RDDynamicCellTableViewVC {
    private let currentPerson: RDPerson
    private let date: Date
    private var settings = RDBookingSettings()
    private let availablePersons: [PersonAppointments]
    private var selectedPerson: RDPerson?
    
    override var navigationBarTitle: String? {
        return "Appointment settings"
    }
    
    
    init(person: RDPerson, date: Date) {
        self.currentPerson = person
        self.date = date
        self.availablePersons = RDAppointmentsManager().loadAllPersons()
        
        if availablePersons.count > 0 {
            selectedPerson = availablePersons[0].0
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
    }
    
    
    private func setupData() {
        let firstSection = [
            createDurationPicker()
        ]
        
        var secondSection = [RDCellData]()
        let persons = availablePersons.map { $0.0 }.filter { $0.appointmentsFilePath != currentPerson.appointmentsFilePath }
        for (index, person) in persons.enumerated() {
            let data = RDOptionPickerData(optionID: person.appointmentsFilePath, title: person.name, isSelected: { [unowned self] uid in
                return self.selectedPerson?.appointmentsFilePath == person.appointmentsFilePath
            }) { [unowned self] uid, isSelected in
                if isSelected {
                    self.selectedPerson = persons.first { $0.appointmentsFilePath == uid }
                    self.reloadOptionPickerCells(except: IndexPath(row: index, section: 1))
                } else {
                    self.selectedPerson = nil
                }
            }
            
            secondSection.append(data)
        }
        
        let thirdSection = [
            RDButtonData(type: .action(title: "Select Appointment Time")) { [unowned self] in
                if let _selectedPerson = self.selectedPerson {
                    let firstData = self.availablePersons.first { $0.0.appointmentsFilePath == _selectedPerson.appointmentsFilePath }
                    let secondData = self.availablePersons.first { $0.0.appointmentsFilePath == self.currentPerson.appointmentsFilePath }
                    
                    guard let _firstData = firstData, let _secondData = secondData else { return }
                    let timeGraph = RDAppointmentTimeGraph(personsData: [_firstData, _secondData], date: self.date)
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
}
