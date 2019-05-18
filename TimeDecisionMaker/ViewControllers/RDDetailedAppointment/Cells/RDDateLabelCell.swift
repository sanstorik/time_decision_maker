


import UIKit


class RDDateLabelData: RDCellData {
    override var identifier: String { return RDDateLabelCell.identifier }
    
    let title: String?
    let retrieve: () -> Date?
    var isDatePickerPresented = false
    private(set) var didSelect: ((_ isPickerPresented: Bool, _ at: IndexPath) -> Void)?
    
    init(title: String?, retrieve: @escaping () -> Date?) {
        self.title = title
        self.retrieve = retrieve
    }
    
    func setDidSelect(didSelect: @escaping (_ isPickerPresented: Bool, _ at: IndexPath) -> Void) {
        self.didSelect = didSelect
    }
}


class RDDateLabelCell: RDTemplateCell, HighlightableView {
    var highlightAnimationRunning = false
    override class var identifier: String { return "RDDateLabelCell" }
    override var canBecomeHighlighted: Bool { return true }

    
    private let label: DoubleSidedLabel = {
        let label = DoubleSidedLabel(frame: CGRect.zero, titleLabelOffset: -5)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = UIColor.white
        return label
    }()
    
    
    override func setupFrom(data: RDCellData) {
        super.setupFrom(data: data)
        guard let dateLabelData = data as? RDDateLabelData else { return }
        
        label.text = dateLabelData.title
        label.rightSideLabel.text = dateLabelData.retrieve()?.readableDateTimeString()
        updateLabelsAppearences(isPickerPresented: dateLabelData.isDatePickerPresented)
    }
    
    
    override func setupViews() {
        super.setupViews()
        addSubview(label)
        label.leadingAnchor.constraint(equalTo: leadingA, constant: leadingConstant).isActive = true
        label.trailingA.constraint(equalTo: trailingA, constant: -leadingConstant).isActive = true
        label.topAnchor.constraint(equalTo: topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    
    override func didUnhighlight() {
        changeColorOnUnhighlight()
    }
    
    
    override func didSelect() {
        runSelectColorAnimation()
        selectWithoutAnimation()
    }
    
    
    func forceHideDatePicker() {
        if let labelData = data as? RDDateLabelData, labelData.isDatePickerPresented {
            selectWithoutAnimation()
        }
    }
    
    
    private func selectWithoutAnimation() {
        guard let labelData = data as? RDDateLabelData, let indexPath = labelData.indexPath else { return }
        labelData.isDatePickerPresented = !labelData.isDatePickerPresented
        labelData.didSelect?(labelData.isDatePickerPresented, indexPath)
        updateLabelsAppearences(isPickerPresented: labelData.isDatePickerPresented)
    }

    
    private func updateLabelsAppearences(isPickerPresented: Bool) {
        let color = isPickerPresented ? AppColors.alertSheetDarkButtonColor : UIColor.white
        label.textColor = color
        label.rightSideLabel.textColor = color
    }
}
