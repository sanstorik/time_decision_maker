


import UIKit


class RDDatePickerData: RDCellData {
    override var identifier: String { return RDDatePickerCell.identifier }
    override var rowHeightMultiplier: CGFloat { return 0.24 }
    
    let maximumDate: () -> Date?
    let minimumDate: () -> Date?
    let save: (Date) -> Void
    let retrieve: () -> Date?
    let isWholeDay: () -> Bool
    var pickerMode: UIDatePicker.Mode?
    
    init(minimumDate: @escaping () -> Date?,
         maximumDate: @escaping () -> Date?, isWholeDay: @escaping () -> Bool,
         save: @escaping (Date) -> Void, retrieve: @escaping () -> Date?) {
        self.maximumDate = maximumDate
        self.minimumDate = minimumDate
        self.isWholeDay = isWholeDay
        self.save = save
        self.retrieve = retrieve
    }
}


class RDDatePickerCell: RDTemplateCell {
    override class var identifier: String { return "RDDatePickerCell" }
    override var canBecomeHighlighted: Bool { return true }
    
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.timeZone = TimeZone(secondsFromGMT: 0)
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = .dateAndTime
        picker.setValue(UIColor.white, forKey: "textColor")
        return picker
    }()
    
    
    override func setupFrom(data: RDCellData) {
        super.setupFrom(data: data)
        guard let datePickerData = data as? RDDatePickerData else { return }
        datePicker.minimumDate = datePickerData.minimumDate()
        datePicker.maximumDate = datePickerData.maximumDate()
        datePicker.date = datePickerData.retrieve() ?? Date()
        datePicker.minuteInterval = 5
        datePicker.locale = Locale(identifier: "en_GB")
        
        if let pickerMode = datePickerData.pickerMode {
            datePicker.datePickerMode = pickerMode
        } else {
            datePicker.datePickerMode = datePickerData.isWholeDay() ? .date : .dateAndTime
        }
    }
    
    
    override func setupViews() {
        super.setupViews()
        addSubview(datePicker)
        datePicker.leadingAnchor.constraint(equalTo: leadingA, constant: leadingConstant).isActive = true
        datePicker.trailingA.constraint(equalTo: trailingA, constant: -leadingConstant).isActive = true
        datePicker.topAnchor.constraint(equalTo: topAnchor).isActive = true
        datePicker.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        datePicker.addTarget(self, action: #selector(dateDidChange), for: .valueChanged)
    }
    
    
    @objc private func dateDidChange() {
        (data as? RDDatePickerData)?.save(datePicker.date)
    }
}
