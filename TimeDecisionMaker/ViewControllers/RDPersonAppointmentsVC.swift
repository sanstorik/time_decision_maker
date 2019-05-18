

import UIKit



class RDPersonAppoinmentsVC: CommonVC {
    private let person: RDPerson
    private let appointments: [RDAppointment]
    private let date: Date
    private var appointmentsTableView: UITableView!
    
    private var navigationTitle: String {
        if let name = person.name {
            return "\(name), \(date.readableDateString())"
        } else {
            return date.readableDateString()
        }
    }
    
    
    init(person: RDPerson, appointments: [RDAppointment], date: Date) {
        self.person = person
        self.appointments = appointments.filterByDate(date).sortedByStartDate()
        self.date = date
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        self.person = RDPerson(appointmentsFilePath: nil)
        self.appointments = []
        self.date = Date()
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupBackground(AppColors.messengerBackgroundColor)
        setupNavigationBar(title: navigationTitle, bgColor: AppColors.incomingMessageColor)
    }
}


extension RDPersonAppoinmentsVC {
    private func setupViews() {
        appointmentsTableView = UITableView(frame: .zero, style: .grouped)
        appointmentsTableView.translatesAutoresizingMaskIntoConstraints = false
        appointmentsTableView.backgroundColor = UIColor.clear
        appointmentsTableView.estimatedRowHeight = 0
        appointmentsTableView.estimatedSectionFooterHeight = 0
        appointmentsTableView.estimatedSectionHeaderHeight = 0
        appointmentsTableView.separatorInset = .zero
        
        if #available(iOS 11, *) {
            appointmentsTableView.insetsContentViewsToSafeArea = true
        }
        
        view.addSubview(appointmentsTableView)
        appointmentsTableView.topAnchor.constraint(equalTo: view.topSafeAnchorIOS11(self)).isActive = true
        appointmentsTableView.bottomAnchor.constraint(equalTo: view.bottomSafeAnchorIOS11(self)).isActive = true
        appointmentsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        appointmentsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        appointmentsTableView.register(RDAppointmentCell.self, forCellReuseIdentifier: RDAppointmentCell.identifier)
        
        appointmentsTableView.dataSource = self
        appointmentsTableView.delegate = self
    }
}


extension RDPersonAppoinmentsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appointments.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier:
            RDAppointmentCell.identifier, for: indexPath) as? RDAppointmentCell else {
                fatalError()
        }
        
        cell.appointment = appointments[indexPath.row]
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.deviceHeight * 0.08
    }
}




fileprivate class RDAppointmentCell: UITableViewCell {
    class var identifier: String { return "RDAppointmentCell" }
    
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
    
    private let timeLabel: UILabel = {
        let label = UILabel.defaultInit()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.white
        label.textAlignment = .right
        label.numberOfLines = 0
        return label
    }()
    
    
    private let titleLabel: UILabel = {
        let label = UILabel.defaultInit()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = UIColor.white
        label.numberOfLines = 2
        return label
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
        contentView.backgroundColor = AppColors.incomingMessageColor
        
        separatorView = UIView.separatorNoConstraints(
            self, color: UIColor.gray, heightAnchor, width: 1.2, multiplier: 0.9)
        
        addSubview(timeLabel)
        addSubview(separatorView)
        addSubview(titleLabel)
        
        let constraints = [
            timeLabel.leadingAnchor.constraint(equalTo: leadingA, constant: frame.height * 0.1),
            timeLabel.topAnchor.constraint(equalTo: topAnchor),
            timeLabel.widthAnchor.constraint(equalToConstant: frame.height * 1.5),
            timeLabel.heightAnchor.constraint(equalTo: heightAnchor),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -frame.height * 0.05),
            separatorView.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: frame.height * 0.3),
            
            titleLabel.leadingAnchor.constraint(equalTo: separatorView.trailingAnchor, constant: 15),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.heightAnchor.constraint(equalTo: heightAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}
