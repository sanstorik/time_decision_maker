

protocol HashableManagedObject: class {
    associatedtype HashValueHolder: Hashable & Equatable
    var hashHolder: HashValueHolder { get }
}

extension Array where Element: HashableManagedObject {
    func distinct() -> [Element] {
        var used = Set<Element.HashValueHolder>()
        var res = [Element]()
        
        forEach { element in
            if !used.contains(element.hashHolder) {
                res.append(element)
                used.insert(element.hashHolder)
            }
        }
        
        return res
    }
}
