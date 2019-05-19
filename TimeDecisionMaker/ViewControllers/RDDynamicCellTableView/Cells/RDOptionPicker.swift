


import UIKit


class RDOptionPickerData: RDCellData {
    override var identifier: String { return RDOptionPickerCell.identifier }
    
    let optionID: String
    let title: String?
    let didSelect: (String, Bool) -> Void
    let isSelected: (String) -> Bool
    
    init(optionID: String, title: String?, isSelected: @escaping (String) -> Bool,
         didSelect: @escaping (String, Bool) -> Void) {
        self.optionID = optionID
        self.title = title
        self.isSelected = isSelected
        self.didSelect = didSelect
    }
}


class RDOptionPickerCell: RDTemplateCell, HighlightableView {
    private var isOptionPicked = false
    var highlightAnimationRunning = false
    
    override class var identifier: String { return "RDOptionPickerCell" }
    override var canBecomeHighlighted: Bool { return true }
    
    
    private let label: UILabel = {
        let label = UILabel.defaultInit()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = UIColor.white
        label.backgroundColor = .clear
        return label
    }()
    
    
    override func setupFrom(data: RDCellData) {
        super.setupFrom(data: data)
        guard let optionData = data as? RDOptionPickerData else { return }
        
        label.text = optionData.title
        isOptionPicked = optionData.isSelected(optionData.identifier)
        accessoryType = isOptionPicked ? .checkmark : .none
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
        super.didUnhighlight()
        changeColorOnUnhighlight()
    }
    
    
    override func didSelect() {
        super.didSelect()
        runSelectColorAnimation()
        
        guard let optionData = data as? RDOptionPickerData else { return }
        isOptionPicked = !isOptionPicked
        accessoryType = isOptionPicked ? .checkmark : .none
        optionData.didSelect(optionData.optionID, isOptionPicked)
    }
}
