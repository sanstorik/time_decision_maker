
import UIKit


class RDDynamicCellTableViewVC: CommonVC, FullScreenTableViewHolder {
    private(set) var tableView: UITableView!
    var presentedPickerIndexPath: IndexPath?
    var data = [[RDCellData]]()
    var navigationBarTitle: String? { return nil }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground(AppColors.messengerBackgroundColor)
        setupNavigationBar(title: navigationBarTitle ?? "", bgColor: AppColors.incomingMessageColor)
        setupViews()
    }
    
    
    private func setupViews() {
        tableView = setupTableView(bottomAnchor: view.bottomSafeAnchorIOS11(self))
        
        let customCells = [
            RDTextFieldCell.self, RDBooleanCell.self,
            RDDateLabelCell.self, RDDatePickerCell.self,
            RDButtonCell.self, RDTimeCell.self,
            RDOptionPickerCell.self]
        
        customCells.forEach {
            tableView.register($0.self, forCellReuseIdentifier: $0.identifier)
        }
    }
    
    
    private func updatedCellIndexPathIncludingPresentedDatePicker(_ indexPath: IndexPath) -> IndexPath {
        if let _pickerIndexPath = presentedPickerIndexPath, indexPath.section == _pickerIndexPath.section,
            indexPath.row >= _pickerIndexPath.row {
            return IndexPath(row: indexPath.row - 1, section: indexPath.section)
        } else {
            return indexPath
        }
    }
    
    
    final func changePickerModeForDataLabel(isPresented: Bool, at indexPath: IndexPath, for data: RDDatePickerData) {
        let pickerIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
        tableView.deselectRow(at: indexPath, animated: false)
        tableView.deselectRow(at: pickerIndexPath, animated: false)
        
        if isPresented {
            forceHideOtherDatePickers(except: indexPath)
            self.data[indexPath.section].insert(data, at: pickerIndexPath.row)
            self.presentedPickerIndexPath = pickerIndexPath
            tableView.insertRows(at: [pickerIndexPath], with: .fade)
        } else {
            self.data[indexPath.section].remove(at: pickerIndexPath.row)
            self.presentedPickerIndexPath = nil
            tableView.deleteRows(at: [pickerIndexPath], with: .fade)
        }
    }
    
    
    final func forceHideOtherDatePickers(except labelIndexPath: IndexPath) {
        for cell in tableView.visibleCells where cell is RDDateLabelCell {
            let dataCell = cell as! RDDateLabelCell
            if let cellIndexPath = tableView.indexPath(for: dataCell), cellIndexPath == labelIndexPath {
                continue
            }
            
            dataCell.forceHideDatePicker()
        }
    }
    
    
    final func reloadDateCell() {
        let cellsToReload = tableView.visibleCells.filter { $0 is RDDateLabelCell || $0 is RDDatePickerCell }
        let indexPaths = cellsToReload.compactMap { tableView.indexPath(for: $0) }
        tableView.reloadRows(at: indexPaths, with: .none)
    }
}


extension RDDynamicCellTableViewVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataForRow = data[indexPath.section][indexPath.row]
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: dataForRow.identifier, for: indexPath) as? RDTemplateCell else {
                fatalError()
        }
        
        dataForRow.indexPath = updatedCellIndexPathIncludingPresentedDatePicker(indexPath)
        cell.data = dataForRow
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.deviceHeight * data[indexPath.section][indexPath.row].rowHeightMultiplier
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? RDTemplateCell {
            cell.didSelect()
        }
    }
    
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? RDTemplateCell {
            cell.didUnhighlight()
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 20 : 25
    }
}
