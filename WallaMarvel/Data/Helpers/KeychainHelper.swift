//
//  Keychain.swift
//  WallaMarvel
//
//  Created by Angélica Rodrigues on 27/05/2025.
//

import Security
import Foundation

class KeychainHelper {
    
    static func storeData(data: Data, forService service: String, account: String) -> Bool {
        let query: [String: Any] = [
            
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        let status = SecItemAdd (query as CFDictionary, nil)
        return status == errSecSuccess
    }
}
