import Foundation

enum DatabaseError: Error {
    case runtimeError(String)
}

enum PhotoDataError: Error {
    case conversionFailed
}
