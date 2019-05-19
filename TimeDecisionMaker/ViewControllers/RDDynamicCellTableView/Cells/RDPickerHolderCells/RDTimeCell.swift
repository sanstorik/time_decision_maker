


import UIKit


class RDTimeData: RDPickerHolderData {
    override var identifier: String { return RDTimeCell.identifier }
    
    let retrieve: () -> TimeInterval
    
    init(title: String?, retrieve: @escaping () -> TimeInterval) {
        self.retrieve = retrieve
        super.init(title: title)
    }
}


class RDTimeCell: RDPickerHolderCell {
    override class var identifier: String { return "RDTimeCell" }
    
    
    override func setupFrom(data: RDCellData) {
        super.setupFrom(data: data)
        guard let dateLabelData = data as? RDTimeData else { return }
        label.rightSideLabel.text = Date.stringFromTimeInterval(interval: dateLabelData.retrieve())
        updateLabelsAppearences(isPickerPresented: dateLabelData.isDatePickerPresented)
    }
}
