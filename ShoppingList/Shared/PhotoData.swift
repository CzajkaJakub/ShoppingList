import Foundation
import SQLite

extension Data {
    func toBlob() -> Blob {
        return Blob(bytes: [UInt8](self))
    }
}
