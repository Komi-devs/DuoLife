import Foundation
import CryptoKit

func encryptPassword(_ password: String, withMaster master: String) -> Data? {
    let key = SymmetricKey(data: SHA256.hash(data: Data(master.utf8)))
    let data = Data(password.utf8)
    if let sealed = try? AES.GCM.seal(data, using: key) {
        return sealed.combined
    }
    return nil
}

func decryptPassword(_ encryptedData: Data, withMaster master: String) -> String? {
    let key = SymmetricKey(data: SHA256.hash(data: Data(master.utf8)))
    if let sealed = try? AES.GCM.SealedBox(combined: encryptedData),
       let decrypted = try? AES.GCM.open(sealed, using: key) {
        return String(data: decrypted, encoding: .utf8)
    }
    return nil
}
