
import UIKit


class RDAppointmentTimeGraph: CommonVC {
    private let hoursTexts = ["12", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11",
                              "Noon", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
    private let personsData: [PersonAppointments]
    private let appointmentsManager = RDAppointmentsManager()
    private var scrollView: UIScrollView!
    private var graph: UIView!
    
    
    init(personsData: [PersonAppointments]) {
        self.personsData = personsData
        super.init(nibName: nil, bundle: nil)
    }

    
    required init?(coder aDecoder: NSCoder) {
        self.personsData = []
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar(title: "Time graph", bgColor: AppColors.incomingMessageColor)
        setupBackground(AppColors.messengerBackgroundColor)
        setupViews()
    }
    
    
    private func setupViews() {
        scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.leadingAnchor.constraint(equalTo: view.leadingA).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingA).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topSafeAnchorIOS11(self)).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomSafeAnchorIOS11(self)).isActive = true
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.isScrollEnabled = true
        scrollView.isUserInteractionEnabled = true
        
        graph = UIView()
        scrollView.addSubview(graph)
        graph.translatesAutoresizingMaskIntoConstraints = false
        graph.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        graph.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        graph.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        graph.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        graph.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        var topAnchor = graph.topAnchor
        var spacing: CGFloat = 5
        for i in 0..<24 {
            let hourLine = createHourLine(inside: graph, topAnchor: topAnchor, spacing: spacing, index: i)
            topAnchor = hourLine.bottomAnchor
            spacing = 30
            
            if i == 23 {
                hourLine.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
            }
        }
    }
    
    
    private func createHourLine(inside graph: UIView, topAnchor: NSLayoutYAxisAnchor, spacing: CGFloat, index: Int) -> HourLine {
        let view = HourLine()
        graph.addSubview(view)
        let hour = "\(hoursTexts[index]) \(index == 12 ? "" : (index <= 11 ? "AM" : "PM"))"
        view.hourLabel.text = hour
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: graph.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: graph.trailingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: topAnchor, constant: spacing).isActive = true
        view.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        return view
    }
}


class HourLine: UIView {
    let hourLabel: UILabel = {
        let label = UILabel.defaultInit()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    
    private let line: UIView = {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = UIColor.lightGray
        return line
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    
    private func setupViews() {
        addSubview(hourLabel)
        addSubview(line)
        
        let constraints = [
            hourLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            hourLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            line.leadingAnchor.constraint(equalTo: hourLabel.trailingAnchor, constant: 4),
            line.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            line.centerYAnchor.constraint(equalTo: centerYAnchor),
            line.heightAnchor.constraint(equalToConstant: 0.4)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}
