


import UIKit


class RDButtonData: RDCellData {
    override var identifier: String { return RDButtonCell.identifier }
    
    enum RDButtonType {
        case list(title: String), action(title: String), valuePicker(title: String?, value: () -> String?)
    }
    
    let type: RDButtonType
    let didSelect: () -> Void
    
    init(type: RDButtonType, didSelect: @escaping () -> Void) {
        self.type = type
        self.didSelect = didSelect
    }
}


class RDButtonCell: RDTemplateCell, HighlightableView {
    var highlightAnimationRunning = false
    
    override class var identifier: String { return "RDButtonCell" }
    override var canBecomeHighlighted: Bool { return true }
    private var buttonView: ButtonActionView!
    
    
    override func setupFrom(data: RDCellData) {
        super.setupFrom(data: data)
        guard let buttonData = data as? RDButtonData else { return }
        
        switch buttonData.type {
        case .action(let title):
            buttonView.type = .action
            buttonView.label.text = title
        case .list(let title):
            buttonView.type = .list
            buttonView.label.text = title
        case .valuePicker(let title, let value):
            buttonView.type = .valuePicker
            buttonView.label.text = title
            buttonView.valueLabel.text = value()
        }
    }
    
    
    override func setupViews() {
        super.setupViews()
        buttonView = ButtonActionView(offset: leadingConstant, iconMultiplier: 0.4)
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(buttonView)
        buttonView.leadingAnchor.constraint(equalTo: leadingA).isActive = true
        buttonView.trailingA.constraint(equalTo: trailingA).isActive = true
        buttonView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        buttonView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    
    override func didUnhighlight() {
        changeColorOnUnhighlight()
    }
    
    
    override func didSelect() {
        runSelectColorAnimation()
        (data as? RDButtonData)?.didSelect()
    }
}
