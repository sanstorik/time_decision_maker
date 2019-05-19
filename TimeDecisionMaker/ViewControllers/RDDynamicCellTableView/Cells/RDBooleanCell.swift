

import UIKit


class RDBooleanData: RDCellData {
    override var identifier: String { return RDBooleanCell.identifier }
    
    let title: String?
    let save: (Bool) -> Void
    let retrieve: () -> Bool
    
    init(title: String?, save: @escaping (Bool) -> Void, retrieve: @escaping () -> Bool) {
        self.title = title
        self.save = save
        self.retrieve = retrieve
    }
}


class RDBooleanCell: RDTemplateCell, HighlightableView {
    var highlightAnimationRunning = false
    
    override class var identifier: String { return "RDBooleanCell" }
    override var canBecomeHighlighted: Bool { return true }
    private var labeledSwitch: LabeledSwitch!
    
    
    override func setupFrom(data: RDCellData) {
        super.setupFrom(data: data)
        guard let booleanData = data as? RDBooleanData else { return }
        
        labeledSwitch.isOn = booleanData.retrieve()
        labeledSwitch.label.text = booleanData.title
        labeledSwitch.label.textColor = UIColor.white
        labeledSwitch.label.font = UIFont.systemFont(ofSize: 17)
    }
    
    
    override func setupViews() {
        super.setupViews()
        labeledSwitch = LabeledSwitch(offset: frame.width * 0.035, switchOffsetFromRight: -leadingConstant)
        labeledSwitch.translatesAutoresizingMaskIntoConstraints = false
        addSubview(labeledSwitch)
        
        labeledSwitch.leadingAnchor.constraint(equalTo: leadingA).isActive = true
        labeledSwitch.trailingAnchor.constraint(equalTo: trailingA).isActive = true
        labeledSwitch.topAnchor.constraint(equalTo: topAnchor).isActive = true
        labeledSwitch.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        labeledSwitch.didChangeValue = { [unowned self] in
            (self.data as? RDBooleanData)?.save($0)
        }
    }
    
    
    override func didUnhighlight() {
        changeColorOnUnhighlight()
    }
    
    
    override func didSelect() {
        runSelectColorAnimation()
    }
}
