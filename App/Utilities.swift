import Foundation

extension Int {
    
    var dateValue: Date {
        return Date(timeIntervalSince1970: Double(self))
    }
    
}

extension Date {
    
    var readable: String {
        let formatter = DateFormatter()
        #if os(Linux)
            formatter.dateStyle = .shortStyle
            formatter.timeStyle = .mediumStyle
        #else
            formatter.dateStyle = .short
            formatter.timeStyle = .medium
        #endif
        return formatter.string(from: self)
    }
    
}
