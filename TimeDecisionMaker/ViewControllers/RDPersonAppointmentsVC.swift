

import UIKit


class RDPersonAppoinmentsVC: CommonVC {
    private let person: RDPerson
    private let date: Date
    private var appointments = [[RDAppointment]]()
    private var appointmentsTableView: UITableView!
    private let appointmentsManager = RDAppointmentsManager()
    private var bookingButton: ButtonActionView!
    
    private var navigationTitle: String {
        if let name = person.name {
            return "\(name), \(date.readableDateString())"
        } else {
            return date.readableDateString()
        }
    }
    
    
    init(person: RDPerson, date: Date) {
        self.person = person
        self.date = date
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupBackground(AppColors.messengerBackgroundColor)
        setupNavigationBar(title: navigationTitle, bgColor: AppColors.incomingMessageColor)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateModelFrom(appointments: appointmentsManager.loadEvents(for: person))
        appointmentsTableView.reloadData()
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
        appointmentsManager.updateEvents(for: person, changing: [updatedAppointment])
    }
    
    
    @objc private func didClickBookingButton() {
        let bookingSettings = RDAppointmentSettingsVC(person: person, date: date)
        navigationController?.pushViewController(bookingSettings, animated: true)
        bookingButton.runSelectColorAnimation()
    }
}


extension RDPersonAppoinmentsVC: FullScreenTableViewHolder {
    var separatorInset: UIEdgeInsets { return .zero }
    
    
    private func setupViews() {
        bookingButton = ButtonActionView(offset: 0, iconMultiplier: 0)
        bookingButton.label.text = "Schedule an appointment"
        bookingButton.translatesAutoresizingMaskIntoConstraints = false
        bookingButton.type = .action
        
        view.addSubview(bookingButton)
        bookingButton.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bookingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bookingButton.bottomAnchor.constraint(equalTo: view.bottomSafeAnchorIOS11(self)).isActive = true
        bookingButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        bookingButton.backgroundColor = AppColors.incomingMessageColor
        bookingButton.addTapClick(target: self, action: #selector(didClickBookingButton))
        
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.layer.borderColor = UIColor.black.cgColor
        separator.layer.borderWidth = 0.5
        let separatorConstraints = [
            separator.leadingAnchor.constraint(equalTo: bookingButton.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: bookingButton.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1),
            separator.bottomAnchor.constraint(equalTo: bookingButton.topAnchor)
        ]
        
        view.addSubview(separator)
        NSLayoutConstraint.activate(separatorConstraints)

        appointmentsTableView = setupTableView(bottomAnchor: bookingButton.topAnchor)
        appointmentsTableView.register(RDAppointmentCell.self, forCellReuseIdentifier: RDAppointmentCell.identifier)
        
        view.bringSubviewToFront(bookingButton)
        view.bringSubviewToFront(separator)
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
        
        cell.date = date
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
    var date: Date!
    var appointment: RDAppointment? {
        didSet {
            if let _appointment = appointment {
                let dateType = _appointment.dateTypeFor(day: date)
                
                let dateTitle: String?
                switch dateType {
                case .startingAndEndingToday(let start, let end):
                    dateTitle = "\(start.readableTimeString())\n\(end.readableTimeString())"
                case .startingToday(let start):
                    dateTitle = "Starts \n\(start.readableTimeString())"
                case .endingToday(let end):
                    dateTitle = "Ends \n\(end.readableTimeString())"
                case .isBetween(let start, let end):
                    dateTitle = "\(start.readableMonthAndDate())\n\(end.readableMonthAndDate())"
                case .wholeDay:
                    dateTitle = "all-day"
                case .unknown:
                    dateTitle = nil
                }
                
                timeLabel.text = dateTitle
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
