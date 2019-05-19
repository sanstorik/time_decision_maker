
import UIKit


class RDAppointmentTimeGraph: CommonVC {
    private let personsData: [PersonAppointments]
    private let appointmentsManager = RDAppointmentsManager()
    
    
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
    }
}
