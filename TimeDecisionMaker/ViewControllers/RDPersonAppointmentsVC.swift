

import UIKit


class RDPersonAppoinmentsVC: CommonVC {
    private let person: RDPerson
    private let date: Date
    private var appointments = [[RDAppointment]]()
    private var appointmentsTableView: UITableView!
    private let appointmentsManager = RDAppointmentsManager()
    
    private var navigationTitle: String {
        if let name = person.name {
            return "\(name), \(date.readableDateString())"
        } else {
            return date.readableDateString()
        }
    }
    
    
    init(person: RDPerson, appointments: [RDAppointment], date: Date) {
        self.person = person
        self.date = date
        super.init(nibName: nil, bundle: nil)
        updateModelFrom(appointments: appointments)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        self.person = RDPerson(appointmentsFilePath: nil)
        self.date = Date()
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupBackground(AppColors.messengerBackgroundColor)
        setupNavigationBar(title: navigationTitle, bgColor: AppColors.incomingMessageColor)
    }
    
    
    private func updateModelFrom(appointments: [RDAppointment]) {
        self.appointments = []
        let (wholeDay, regular) = appointments.filterByDate(date).sortedByStartDate()
        if wholeDay.count > 0 { self.appointments.append(wholeDay) }
        if regular.count > 0 { self.appointments.append(regular) }
    }
    
    
    private func didUpdateAppointment(_ editModel: RDAppointmentEditModel, at indexPath: IndexPath) {
        let updatedAppointment = RDAppointment(editModel: editModel)
        appointments[indexPath.section][indexPath.row] = updatedAppointment
        
        updateModelFrom(appointments: appointments.flatMap { $0 })
        appointmentsManager.updateEvents(for: person, changing: [updatedAppointment])
        appointmentsTableView.reloadData()
    }
}


extension RDPersonAppoinmentsVC: FullScreenTableViewHolder {
    var separatorInset: UIEdgeInsets { return .zero }
    
    
    private func setupViews() {
        appointmentsTableView = setupTableView()
        appointmentsTableView.register(RDAppointmentCell.self, forCellReuseIdentifier: RDAppointmentCell.identifier)
    }
}


extension RDPersonAppoinmentsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return appointments.count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appointments[section].count
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? RDAppointmentCell {
            cell.didSelect()
        }
        
        let detailedAppointmentVC = RDDetailedAppointmentVC(appointments[indexPath.section][indexPath.row])
        detailedAppointmentVC.didChangeAppointment = { [weak self] in
            self?.didUpdateAppointment($0, at: indexPath)
        }
        
        navigationController?.pushViewController(detailedAppointmentVC, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier:
            RDAppointmentCell.identifier, for: indexPath) as? RDAppointmentCell else {
                fatalError()
        }
        
        cell.appointment = appointments[indexPath.section][indexPath.row]
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = AppColors.cellSelectionColor
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.deviceHeight * 0.07
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 20 : 25
    }
    
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? RDAppointmentCell {
            cell.didUnhighlight()
        }
    }
}




fileprivate class RDAppointmentCell: UITableViewCell, HighlightableView {
    class var identifier: String { return "RDAppointmentCell" }
    
    var highlightAnimationRunning = false
    var appointment: RDAppointment? {
        didSet {
            if let _appointment = appointment {
                if _appointment.isWholeDay {
                    timeLabel.text = "all-day"
                } else {
                    timeLabel.text = "Starts \n\(_appointment.start?.readableTimeString() ?? Date().readableTimeString())"
                }
                
                titleLabel.text = _appointment.title
            }
        }
    }
    
    private var separatorView: UIView!
    
    private let timeLabel: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = UIFont.systemFont(ofSize: 15)
        tv.textColor = UIColor.white
        tv.textAlignment = .right
        tv.backgroundColor = .clear
        tv.isUserInteractionEnabled = false
        tv.isEditable = false
        return tv
    }()
    
    
    private let titleLabel: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = UIFont.systemFont(ofSize: 17)
        tv.textColor = UIColor.white
        tv.textAlignment = .left
        tv.backgroundColor = .clear
        tv.isUserInteractionEnabled = false
        tv.isEditable = false
        return tv
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) { /* empty */ }
    
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        separatorView?.backgroundColor = UIColor.gray
    }
    
    
    private func setupViews() {
        backgroundColor = AppColors.incomingMessageColor
        separatorView = UIView.separatorNoConstraints(
            self, color: UIColor.gray, heightAnchor, width: 1.2, multiplier: 0.9)
        
        addSubview(timeLabel)
        addSubview(separatorView)
        addSubview(titleLabel)
        
        let constraints = [
            timeLabel.leadingAnchor.constraint(equalTo: leadingA, constant: frame.height * 0.1),
            timeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 3),
            timeLabel.widthAnchor.constraint(equalToConstant: frame.height * 1.5),
            timeLabel.heightAnchor.constraint(equalTo: heightAnchor),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -frame.height * 0.05),
            separatorView.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: frame.height * 0.2),
            
            titleLabel.leadingAnchor.constraint(equalTo: separatorView.trailingAnchor, constant: 15),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            titleLabel.heightAnchor.constraint(equalTo: heightAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    
    func didSelect() {
        runSelectColorAnimation()
    }
    
    
    func didUnhighlight() {
        changeColorOnUnhighlight()
    }
}
