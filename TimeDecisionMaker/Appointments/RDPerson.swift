

import Foundation



class RDPerson {
    private(set) var appointmentsFilePath: String?
    
    
    var name: String? {
        if let _filePath = appointmentsFilePath {
            return URL(fileURLWithPath: _filePath).deletingPathExtension().lastPathComponent
        }
        
        return nil
    }
    
    
    init(appointmentsFilePath: String?) {
        self.appointmentsFilePath = appointmentsFilePath
    }
    
    
    init(filename: String) {
        self.appointmentsFilePath = Bundle.main.path(forResource: filename, ofType: ".ics")
    }
    
    
    func updateFilePath(_ filePath: String) {
        appointmentsFilePath = filePath
    }
}
