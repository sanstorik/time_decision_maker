


import UIKit


class RDPickerHolderData: RDCellData {
    override var identifier: String { return RDPickerHolderCell.identifier }
    
    let title: String?
    var isDatePickerPresented = false
    private(set) var didSelect: ((_ isPickerPresented: Bool, _ at: IndexPath) -> Void)?
    
    init(title: String?) {
        self.title = title
    }
    
    func setDidSelect(didSelect: @escaping (_ isPickerPresented: Bool, _ at: IndexPath) -> Void) {
        self.didSelect = didSelect
    }
}


class RDPickerHolderCell: RDTemplateCell, HighlightableView {
    var highlightAnimationRunning = false
    override class var identifier: String { return "RDPickerHolderCell" }
    override var canBecomeHighlighted: Bool { return true }
    
    
    let label: DoubleSidedLabel = {
        let label = DoubleSidedLabel(frame: CGRect.zero, titleLabelOffset: -5)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = UIColor.white
        return label
    }()
    
    
    override func setupFrom(data: RDCellData) {
        super.setupFrom(data: data)
        guard let dateLabelData = data as? RDPickerHolderData else { return }
        label.text = dateLabelData.title
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
    
    
    final func forceHideDatePicker() {
        if let labelData = data as? RDPickerHolderData, labelData.isDatePickerPresented {
            selectWithoutAnimation()
        }
    }
    
    
    final func selectWithoutAnimation() {
        guard let labelData = data as? RDPickerHolderData, let indexPath = labelData.indexPath else { return }
        labelData.isDatePickerPresented = !labelData.isDatePickerPresented
        labelData.didSelect?(labelData.isDatePickerPresented, indexPath)
        updateLabelsAppearences(isPickerPresented: labelData.isDatePickerPresented)
    }
    
    
    final func updateLabelsAppearences(isPickerPresented: Bool) {
        let color = isPickerPresented ? AppColors.alertSheetDarkButtonColor : UIColor.white
        label.textColor = color
        label.rightSideLabel.textColor = color
    }
}
