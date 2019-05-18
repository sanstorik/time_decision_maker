

import Foundation



class RDPerson {
    private(set) var appointmentsFilePath: String?
    
    
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
