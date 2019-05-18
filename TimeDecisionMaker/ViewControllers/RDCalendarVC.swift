

import UIKit

class RDCalendarVC: CommonVC {
    private let calendar: CalendarView = EventsCalendar(frame: CGRect.zero)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground(AppColors.messengerBackgroundColor)
        setupNavigationBar(title: "Calendar", bgColor: AppColors.incomingMessageColor)
        setupViews()
    }
    
    
    private func setupViews() {
        view.addSubview(calendar)
        
        calendar.eventsDelegate = self
        calendar.leadingAnchor.constraint(equalTo: view.leadingA).isActive = true
        calendar.trailingAnchor.constraint(equalTo: view.trailingA).isActive = true
        calendar.topAnchor.constraint(equalTo: view.topSafeAnchorIOS11(self)).isActive = true
        calendar.bottomAnchor.constraint(equalTo: view.bottomSafeAnchorIOS11(self)).isActive = true
        
        calendar.selectDate(Date())
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animateAlongsideTransition(in: nil, animation: nil) { _ in
            self.calendar.recalculateRowsHeight(for: size.height - 10)
        }
        
        super.viewWillTransition(to: size, with: coordinator)
    }
}


extension RDCalendarVC: EventsCalendarDelegate {
    func calendar(_ calendar: EventsCalendar, didSelect date: Date) {
        
    }
    
    
    func calendar(_ calendar: EventsCalendar, numberOfEventsFor date: Date) -> Int {
        return 2
    }
    
    
    func calendar(_ calendar: EventsCalendar, eventDefaultColorsFor date: Date) -> [UIColor]? {
        return [UIColor.white, UIColor.white]
    }
    
    
    func calendar(_ calendar: EventsCalendar, willDisplay cell: EventsCalendarDateCell, for date: Date) {
        
    }
    
    
    func calendar(_ calendar: EventsCalendar, eventSelectionColorsFor date: Date) -> [UIColor]? {
        return [AppColors.colorPrimaryLight, AppColors.colorPrimaryLight]
    }
}
