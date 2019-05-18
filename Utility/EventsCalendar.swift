
import UIKit
import FSCalendar


typealias CalendarView = ICalendar & UIView
protocol ICalendar: class {
    var eventsDelegate: EventsCalendarDelegate? { get set }
    func reloadEventData()
    func recalculateRowsHeight(for height: CGFloat)
    func selectDate(_ date: Date)
}


class EventsCalendar: FSCalendar, ICalendar {
    private var cellData: (AnyClass, String)!
    var eventSelectedDate: Date? { return self.selectedDate }
    weak var eventsDelegate: EventsCalendarDelegate?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        translatesAutoresizingMaskIntoConstraints = false
        delegate = self
        dataSource = self
        setupCell(EventsCalendarCell.self, identifier: EventsCalendarCell.identifier)
        
        appearance.weekdayTextColor = UIColor.white
        appearance.headerTitleColor = UIColor.white
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func selectDate(_ date: Date) {
        select(date)
    }
    
    
    func reloadEventData() {
        reloadData()
    }
    
    
    final func recalculateRowsHeight(for height: CGFloat) {
        let prefferedHeaderHeight = UIDevice.isPhone && UIDevice.isLandscape ? 0 : FSCalendarStandardHeaderHeight
        
        // hide month header for iphone in landscape
        if UIDevice.isPhone {
            headerHeight = prefferedHeaderHeight
            setNeedsLayout()
            layoutIfNeeded()
        }
        
        daysContainer.frame = CGRect(x: contentView.frame.minX, y: daysContainer.frame.minY,
                                     width: daysContainer.frame.width,
                                     height: height - contentView.frame.minY - prefferedHeaderHeight * 2)
        collectionView.frame = CGRect(x: contentView.frame.minX, y: collectionView.frame.minY,
                                      width: collectionView.frame.width,
                                      height: height - contentView.frame.minY - prefferedHeaderHeight * 2)
        
        collectionViewLayout.invalidateLayout()
    }
    
    
    private func setupCell(_ cellClass: AnyClass, identifier: String) {
        cellData = (cellClass, identifier)
        register(cellClass, forCellReuseIdentifier: identifier)
    }
}


protocol EventsCalendarDelegate: class {
    func calendar(_ calendar: EventsCalendar, didSelect date: Date)
    func calendar(_ calendar: EventsCalendar, numberOfEventsFor date: Date) -> Int
    func calendar(_ calendar: EventsCalendar, eventDefaultColorsFor date: Date) -> [UIColor]?
    func calendar(_ calendar: EventsCalendar, setup cell: EventsCalendarDateCell, for date: Date)
    func calendar(_ calendar: EventsCalendar, willDisplay cell: EventsCalendarDateCell, for date: Date)
    
    func calendar(_ calendar: EventsCalendar, titleOffsetFor date: Date) -> CGPoint
    func calendar(_ calendar: EventsCalendar, eventOffsetFor date: Date) -> CGPoint
    func calendar(_ calendar: EventsCalendar, titleSelectionColorFor date: Date) -> UIColor?
    func calendar(_ calendar: EventsCalendar, eventSelectionColorsFor date: Date) -> [UIColor]?
    func calendar(_ calendar: EventsCalendar, titleDefaultColorFor date: Date) -> UIColor?
}


protocol EventsCalendarDateCell: class { }


extension EventsCalendarDelegate {
    func calendar(_ calendar: EventsCalendar, setup cell: EventsCalendarDateCell, for date: Date) {
        
    }
    
    
    func calendar(_ calendar: EventsCalendar, titleOffsetFor date: Date) -> CGPoint {
        return CGPoint(x: 0, y: 3.5)
    }
    
    
    func calendar(_ calendar: EventsCalendar, eventOffsetFor date: Date) -> CGPoint {
        return CGPoint(x: 0, y: -2)
    }
    
    
    func calendar(_ calendar: EventsCalendar, titleSelectionColorFor date: Date) -> UIColor? {
        return AppColors.labelOrderFillerColor
    }
    
    
    func calendar(_ calendar: EventsCalendar, eventSelectionColorsFor date: Date) -> [UIColor]? {
        return nil
    }
    
    
    func calendar(_ calendar: EventsCalendar, titleDefaultColorFor date: Date) -> UIColor? {
        return UIColor.white
    }
}


extension EventsCalendar: FSCalendarDataSource, FSCalendarDelegate , FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let timeSizeOffset = TimeInterval(exactly: NSTimeZone.local.secondsFromGMT()) ?? 0
        let dateWithTimeZone = Date(timeInterval: timeSizeOffset, since: date)
        eventsDelegate?.calendar(self, didSelect: dateWithTimeZone)
    }
    
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return eventsDelegate?.calendar(self, numberOfEventsFor: date) ?? 0
    }
    
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        return eventsDelegate?.calendar(self, eventDefaultColorsFor: date)
    }
    
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = dequeueReusableCell(withIdentifier: cellData.1, for: date, at: position)
        if let eventsCell = cell as? EventsCalendarDateCell {
            eventsDelegate?.calendar(self, setup: eventsCell, for: date)
        }
        
        return cell
    }
    
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date,
                  at monthPosition: FSCalendarMonthPosition) {
        guard let cell = cell as? EventsCalendarDateCell else { fatalError() }
        eventsDelegate?.calendar(self, willDisplay: cell, for: date)
    }
    
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleOffsetFor date: Date) -> CGPoint {
        return eventsDelegate?.calendar(self, titleOffsetFor: date) ?? CGPoint.zero
    }
    
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventOffsetFor date: Date) -> CGPoint {
        return eventsDelegate?.calendar(self, eventOffsetFor: date) ?? CGPoint.zero
    }
    
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleSelectionColorFor date: Date) -> UIColor? {
        return eventsDelegate?.calendar(self, titleSelectionColorFor: date)
    }
    
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventSelectionColorsFor date: Date) -> [UIColor]? {
        return eventsDelegate?.calendar(self, eventSelectionColorsFor: date)
    }
    
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        return eventsDelegate?.calendar(self, titleDefaultColorFor: date)
    }
    
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        
    }
}


fileprivate class EventsCalendarCell: FSCalendarCell, EventsCalendarDateCell {
    static let identifier = "calendarCell"
    
    private var selectionLayer: CAShapeLayer!
    var todosEventsIndicator: TodoEventsCalendarIndicator!
    
    required init!(coder aDecoder: NSCoder!) {
        fatalError()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let selectionLayer = CAShapeLayer()
        selectionLayer.fillColor = AppColors.headerColor.cgColor
        selectionLayer.actions = ["hidden": NSNull()]
        self.contentView.layer.insertSublayer(selectionLayer, below: self.titleLabel!.layer)
        self.selectionLayer = selectionLayer
        self.shapeLayer.isHidden = true
        
        let view = UIView(frame: self.bounds)
        self.backgroundView = view;
        
        self.todosEventsIndicator = TodoEventsCalendarIndicator()
        addSubview(todosEventsIndicator)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundView?.frame = self.bounds
        self.selectionLayer.frame = self.contentView.bounds
        self.todosEventsIndicator.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height * 0.3)
    }
    
    
    override func configureAppearance() {
        super.configureAppearance()
        
        if isPlaceholder {
            eventIndicator.isHidden = true
            titleLabel.textColor = UIColor.gray
            todosEventsIndicator.shouldBeHidden = true
        } else if isSelected {
            backgroundView?.backgroundColor = AppColors.alertSheetDarkButtonColor.withAlphaComponent(0.2)
        } else {
            self.backgroundView?.backgroundColor = AppColors.incomingMessageColor
        }
    }
}



fileprivate class TodoEventsCalendarIndicator: UIView {
    private var events = [CALayer]()
    
    var shouldBeHidden = false
    let maxEventsCount = 3
    var eventsCount = 0 {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    private func setupViews() {
        for _ in 0..<3 {
            let layer = CALayer()
            layer.backgroundColor = UIColor.brown.cgColor
            events.append(layer)
            
            self.layer.addSublayer(layer)
        }
    }
    
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        let width = min(min(frame.width, frame.height), FSCalendarMaximumEventDotDiameter)
        let offset: CGFloat = frame.width * 0.5 - CGFloat(CGFloat(eventsCount) * width) + 2
        
        if layer == self.layer {
            for i in 0..<events.count {
                events[i].isHidden = shouldBeHidden || i >= eventsCount
                events[i].frame = CGRect(x: offset + CGFloat(i) * width * 2, y: frame.height * 0.5,
                                         width: width, height: frame.height * 0.4)
            }
        }
    }
}
