import Foundation

class StringUtils {
    
    static func convertTextFieldToDouble(stringValue: String) -> Double? {
        return Double(stringValue.replacingOccurrences(of: ",", with: "."))
    }
}
