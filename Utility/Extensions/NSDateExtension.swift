import Foundation

fileprivate let defaultCalendar: Foundation.Calendar = {
    var calendar = Foundation.Calendar(identifier: .gregorian)
    if let timeZone = TimeZone(secondsFromGMT: 0) {
        calendar.timeZone = timeZone
    }
    return calendar
}()


fileprivate let microsecondsFormatter = MicrosecondPrecisionDateFormatter()
fileprivate let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yyyy"
    formatter.timeZone = TimeZone.current
    return formatter
}()


fileprivate let dateTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yyyy HH:mm"
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter
}()


fileprivate let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter
}()


extension NSDate {
    func readableDateString() -> String {
        return dateFormatter.string(from: self as Date)
    }
    
    func readableDateTimeString() -> String {
        return dateTimeFormatter.string(from: self as Date)
    }
    
    func formatDate() -> String {
        return microsecondsFormatter.string(from: self as Date)
    }
    
    static func from(string: String) -> NSDate? {
        return microsecondsFormatter.date(from: string) as NSDate?
    }

    
    func readableTimeString() -> String {
        return timeFormatter.string(from: self as Date)
    }
    
    
    func timeSpan() -> String? {
        let secondsFromNowToFinish = timeIntervalSinceNow
        var hours = Int(secondsFromNowToFinish / 3600)
        let minutes = Int((secondsFromNowToFinish - Double(hours) * 3600) / 60)
        let seconds = Int(secondsFromNowToFinish - Double(hours) * 3600 - Double(minutes) * 60 + 0.5)
        var days = 0
        
        if hours > 24 {
            days = hours / 24
            hours %= 24
        }
        
        if hours < 0 || minutes < 0 || seconds < 0 { return nil }
        
        return String(format: "%02d.%02d:%02d:%02d", days, hours, minutes, seconds)
    }
    
    
    static func from(timespan: String) -> NSDate? {
        var days = 0
        var string = timespan
        if let dot = timespan.firstIndex(where: { $0 == "."}),
            let _days = Int(timespan[..<dot]), dot.encodedOffset <= 3 {
            days = _days
            string = String(timespan[String.Index(encodedOffset: dot.encodedOffset + 1)...])
        }
        
        let sliced = string.split(separator: ":", maxSplits: 3,
                                  omittingEmptySubsequences: false)
        
        guard sliced.count == 3 else { return nil }
        
        let hours = Int(sliced[0])!
        let minutes = Int(sliced[1])!
        let seconds = Int(sliced[2])!
        let secondsFromNowToFinish = TimeInterval(exactly: days * 3600 * 24)!
            + TimeInterval(exactly: hours * 3600)! + TimeInterval(exactly: minutes * 60)!
            + TimeInterval(exactly: seconds)!
        
        return NSDate(timeIntervalSince1970: secondsFromNowToFinish)
    }
    
    
    func sameDay(with date: Date) -> Bool {
        return defaultCalendar.compare(self as Date, to: date, toGranularity: .day) == .orderedSame
    }
    
    
    func isBetween(from: Date, to: Date) -> Bool {
        return from.compare(self as Date) == to.compare(self as Date)
    }
    
    
    func compareDay(to: Date) -> ComparisonResult {
        return defaultCalendar.compare(self as Date, to: to, toGranularity: .day)
    }
    
    
    func minusSeconds(_ seconds: TimeInterval) -> NSDate {
        return NSDate(timeIntervalSince1970: timeIntervalSince1970 - seconds)
    }
}


extension Date {
    func formatDate() -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        df.timeZone = TimeZone(secondsFromGMT: 0)
        
        return df.string(from: self)
    }
    
    
    func readableDateTimeString() -> String {
        return dateTimeFormatter.string(from: self)
    }
    
    
    func readableTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: self)
    }
    
    
    func readableDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: self)
    }
    
    
    func readableMonthAndDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: self)
    }
    
    
    func isBetween(from start: Date, to end: Date, useDefaultTimeZone: Bool = false) -> Bool {
        let comparisonResultWithStart = useDefaultTimeZone ?
            Foundation.Calendar.current.compare(self, to: start, toGranularity: .day)
            :
            defaultCalendar.compare(self, to: start, toGranularity: .day)
        let comparisonResultWithEnd = useDefaultTimeZone ?
            Foundation.Calendar.current.compare(self, to: end, toGranularity: .day)
            :
            defaultCalendar.compare(self, to: end, toGranularity: .day)
        
        return (comparisonResultWithStart == .orderedDescending || comparisonResultWithStart == .orderedSame)
            && (comparisonResultWithEnd == .orderedAscending || comparisonResultWithEnd == .orderedSame)
    }
    
    
    func compareDay(to: Date, useDefaultTimeZone: Bool = false) -> ComparisonResult {
        return useDefaultTimeZone ?
            Foundation.Calendar.current.compare(self, to: to, toGranularity: .day) :
            defaultCalendar.compare(self, to: to, toGranularity: .day)
    }
    
    
    func sameDay(with date: Date, useDefaultTimeZone: Bool = false) -> Bool {
        return compareDay(to: date, useDefaultTimeZone: useDefaultTimeZone) == .orderedSame
    }
    
    
    func nextDay() -> Date? {
        return defaultCalendar.date(byAdding: .day, value: 1, to: self)?.changing(hour: 0, minute: 0, second: 0)
    }
    
    
    static func stringFromTimeInterval(interval: TimeInterval) -> String {
        let _interval = Int(interval)
        
        let minutes = (_interval / 60) % 60
        let hours = (_interval / 3600)
        
        return String(format: "%0.2d:%0.2d:00", hours, minutes)
    }
    
    
    func retrieveHoursAndMinutes() -> (Int, Int) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let timeInterval = formatter.string(from: self)
        let parts = timeInterval.split(separator: ":")
        
        if parts.count == 3, let hours = Int(parts[0]), let minutes = Int(parts[1]) {
            return (hours, minutes)
        } else {
            return (0, 0)
        }
    }
    
    
    static func hoursMinutesFromTimeInterval(_ timeInterval: TimeInterval) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: Date.stringFromTimeInterval(interval: timeInterval))
    }
    
    
    func changing(hour: Int, minute: Int, second: Int) -> Date? {
        var components = defaultCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        components.hour = hour
        components.minute = minute
        components.second = second
        return defaultCalendar.date(from: components)
    }
}


fileprivate final class MicrosecondPrecisionDateFormatter: DateFormatter {
    private let microsecondsPrefix = "."
    
    override public init() {
        super.init()
        locale = Locale(identifier: "en_US_POSIX")
        timeZone = TimeZone(secondsFromGMT: 0)
        dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func string(from date: Date) -> String {
        let components = calendar.dateComponents(Set([Foundation.Calendar.Component.nanosecond]), from: date)
        
        let nanosecondsInMicrosecond = Double(1000)
        let microseconds = lrint(Double(components.nanosecond!) / nanosecondsInMicrosecond)
        
        // Subtract nanoseconds from date to ensure string(from: Date) doesn't attempt faulty rounding.
        let updatedDate = calendar.date(byAdding: .nanosecond, value: -(components.nanosecond!), to: date)!
        let dateTimeString = super.string(from: updatedDate).replacingOccurrences(of: "Z", with: "")
        
        let string = String(format: "%@.%06ldZ",
                            dateTimeString,
                            microseconds)
        
        return string
    }
    
    
    override func date(from string: String) -> Date? {
        guard let microsecondsPrefixRange = string.range(of: microsecondsPrefix) else { return nil }
        let microsecondsWithTimeZoneString = String(string.suffix(from: microsecondsPrefixRange.upperBound))
        
        let nonDigitsCharacterSet = CharacterSet.decimalDigits.inverted
        guard let timeZoneRangePrefixRange = microsecondsWithTimeZoneString
            .rangeOfCharacter(from: nonDigitsCharacterSet) else { return nil }
        
        let microsecondsString = String(microsecondsWithTimeZoneString
            .prefix(upTo: timeZoneRangePrefixRange.lowerBound))
        guard let microsecondsCount = Double(microsecondsString) else { return nil }
        
        let dateStringExludingMicroseconds = string
            .replacingOccurrences(of: microsecondsString, with: "")
            .replacingOccurrences(of: microsecondsPrefix, with: "")
        
        guard let date = super.date(from: dateStringExludingMicroseconds) else { return nil }
        let microsecondsInSecond = Double(1000000)
        let dateWithMicroseconds = date + microsecondsCount / microsecondsInSecond
        
        return dateWithMicroseconds
    }
}
