

import Foundation



class RDPerson {
    private(set) var appointmentsFilePath: String
    
    
    var name: String? {
        return URL(fileURLWithPath: appointmentsFilePath).deletingPathExtension().lastPathComponent
    }
    
    
    init(appointmentsFilePath: String) {
        self.appointmentsFilePath = appointmentsFilePath
    }
    
    
    init?(filename: String) {
        if let path = Bundle.main.path(forResource: filename, ofType: ".ics") {
            self.appointmentsFilePath = path
        } else {
            return nil
        }
    }
    
    
    func updateFilePath(_ filePath: String) {
        appointmentsFilePath = filePath
    }
}
