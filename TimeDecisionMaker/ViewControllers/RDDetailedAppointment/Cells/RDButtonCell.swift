


import UIKit


class RDButtonData: RDCellData {
    override var identifier: String { return RDButtonCell.identifier }
    
    let title: String?
    let value: String?
    let didSelect: () -> Void
    
    init(title: String?, value: String?, didSelect: @escaping () -> Void) {
        self.title = title
        self.value = value
        self.didSelect = didSelect
    }
}


class RDButtonCell: RDTemplateCell {
    override class var identifier: String { return "RDButtonCell" }
    override var canBecomeHighlighted: Bool { return true }
    private var buttonView: ButtonActionView!
    
    
    override func setupFrom(data: RDCellData) {
        super.setupFrom(data: data)
        guard let buttonData = data as? RDButtonData else { return }
        buttonView.label.text = buttonData.title
        buttonView.valueLabel.text = buttonData.value
    }
    
    
    override func setupViews() {
        super.setupViews()
        buttonView = ButtonActionView(offset: leadingConstant, iconMultiplier: 0.5)
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(buttonView)
        buttonView.leadingAnchor.constraint(equalTo: leadingA).isActive = true
        buttonView.trailingA.constraint(equalTo: trailingA).isActive = true
        buttonView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        buttonView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    
    override func didUnhighlight() {
        buttonView.changeColorOnUnhighlight()
    }
    
    
    override func didSelect() {
        buttonView.runSelectColorAnimation()
        (data as? RDButtonData)?.didSelect()
    }
}
