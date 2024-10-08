import Foundation

class DateUtils {
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    static let monthYearDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate(Constants.dateFormat_MMMM_yyyy)
        return formatter
    }()
    
    static func convertDoubleToDate(dateNumberValue: Int) -> Date {
        let timeInterval = TimeInterval(dateNumberValue)
        return Date(timeIntervalSince1970: timeInterval)
    }
    
    static func convertDateToDoubleValue(dateToConvert: Date) -> Double {
        return Double(dateToConvert.timeIntervalSince1970)
    }
    
    static func convertDateToMediumFormat(dateToConvert: Date) -> String {
        return DateUtils.dateFormatter.string(from: dateToConvert)
    }
    
    static func convertRangeToShortFormat(monthToConvert: Date) -> String {
        return DateUtils.monthYearDateFormatter.string(from: monthToConvert)
    }
}

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    
    var startOfWeek: Date {
        Calendar.current.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
    }
    
    var endOfWeek: Date {
        var components = DateComponents()
        components.weekOfYear = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfWeek)!
    }
    
    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: startOfDay)
        return Calendar.current.date(from: components)!
    }

    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfMonth)!
    }
}
