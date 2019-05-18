


import UIKit


class RDDatePickerData: RDCellData {
    override var identifier: String { return RDDatePickerCell.identifier }
    override var rowHeightMultiplier: CGFloat { return 0.24 }
    
    let minimumDate: Date?
    let save: (Date) -> Void
    let retrieve: () -> Date?
    
    init(minimumDate: Date?, save: @escaping (Date) -> Void, retrieve: @escaping () -> Date?) {
        self.minimumDate = minimumDate
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
        datePicker.minimumDate = datePickerData.minimumDate
        datePicker.date = datePickerData.retrieve() ?? Date()
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
