


import UIKit


class RDTextFieldData: RDCellData {
    override var identifier: String { return RDTextFieldCell.identifier }
    
    let placeholder: String?
    let save: (String?) -> Void
    let retrieve: () -> String?
    
    init(placeholder: String?, save: @escaping (String?) -> Void, retrieve: @escaping () -> String?) {
        self.placeholder = placeholder
        self.save = save
        self.retrieve = retrieve
    }
}


class RDTextFieldCell: RDTemplateCell, UITextFieldDelegate {
    override class var identifier: String { return "RDTextFieldCell" }
    override var canBecomeHighlighted: Bool { return false }
    
    
    private let textField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.font = UIFont.systemFont(ofSize: 17)
        tf.textColor = UIColor.white
        return tf
    }()
    
    
    override func setupFrom(data: RDCellData) {
        super.setupFrom(data: data)
        guard let textData = data as? RDTextFieldData else { return }
        
        textField.text = textData.retrieve()
        textField.attributedPlaceholder = NSAttributedString(
            string: textData.placeholder ?? "",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    }
    
    
    override func setupViews() {
        super.setupViews()
        addSubview(textField)
        textField.leadingAnchor.constraint(equalTo: leadingA, constant: leadingConstant).isActive = true
        textField.trailingA.constraint(equalTo: trailingA, constant: -leadingConstant).isActive = true
        textField.topAnchor.constraint(equalTo: topAnchor).isActive = true
        textField.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    
    @objc private func textFieldDidChange() {
        (data as? RDTextFieldData)?.save(textField.text)
    }
 
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
