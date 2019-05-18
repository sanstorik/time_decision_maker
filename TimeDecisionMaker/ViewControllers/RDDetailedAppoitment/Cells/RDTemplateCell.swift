

import UIKit


class RDCellData {
    var identifier: String { return RDTemplateCell.identifier }
}


class RDTemplateCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        contentView.backgroundColor = AppColors.incomingMessageColor
        backgroundColor = AppColors.incomingMessageColor
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    final let leadingConstant: CGFloat = 13
    final weak var presenterDelegate: PresenterDelegate?
    final var focusNextField: (() -> Bool)?
    final var onEditStart: (() -> Void)?
    
    
    final var data: RDCellData? {
        didSet {
            if let _data = data {
                setupFrom(data: _data)
            }
        }
    }
    
    
    override func setSelected(_ highlighted: Bool, animated: Bool) { }
    
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if canBecomeHighlighted {
            super.setHighlighted(highlighted, animated: animated)
        }
    }
    
    
    // MARK: Virtual variables
    open class var identifier: String {
        return "RDTemplateCell"
    }
    
    open var canBecomeHighlighted: Bool {
        return false
    }
    
    open var shouldBackgroundColorBeChanged: Bool {
        return true
    }
    
    
    // MARK: Virtual methods
    open func setupFrom(data: RDCellData) { }
    
    open func setupViews() { }
    
    open func onCellBecameFocused() { }
    
    open func changeEditMode(canBeEdited: Bool) { }
    
    open func didSelect() { }
    
    open func didUnhighlight() { }
    
    open func willBeginScrolling() { }
    
    open func scrollAnimationDidEnd() { }
}
