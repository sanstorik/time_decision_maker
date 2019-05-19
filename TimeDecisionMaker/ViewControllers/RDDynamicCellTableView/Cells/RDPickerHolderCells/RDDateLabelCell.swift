


import UIKit


class RDDateLabelData: RDPickerHolderData {
    override var identifier: String { return RDDateLabelCell.identifier }
    
    let isWholeDay: () -> Bool
    let retrieve: () -> Date?
    
    init(title: String?, isWholeDay: @escaping () -> Bool, retrieve: @escaping () -> Date?) {
        self.isWholeDay = isWholeDay
        self.retrieve = retrieve
        super.init(title: title)
    }
}


class RDDateLabelCell: RDPickerHolderCell {
    override class var identifier: String { return "RDDateLabelCell" }
    
    
    override func setupFrom(data: RDCellData) {
        super.setupFrom(data: data)
        guard let dateLabelData = data as? RDDateLabelData else { return }
        label.text = dateLabelData.title
        label.rightSideLabel.text = dateLabelData.isWholeDay() ?
            dateLabelData.retrieve()?.readableDateString()
            :
            dateLabelData.retrieve()?.readableDateTimeString()
        updateLabelsAppearences(isPickerPresented: dateLabelData.isDatePickerPresented)
    }
}
