//
//  File.swift
//
//
//  Created by Eon Fluxor on 1/4/24.
//

import Foundation

extension SecureVault {
    struct EncryptedStore: Codable {
        var store: [String: Data]
    }

    enum EncryptionError: Error {
        case combinedDataNil
        case encryptionFailed(String)
    }

    enum DecryptionError: Error {
        case invalidData
        case decryptionFailed(String)
    }

    actor SecureVaultActor {
        private var store: [String: Data] = [:]

        func set(key: String, value: Data) {
            store[key] = value
        }

        func get(key: String) -> Data? {
            store[key]
        }
    }
}
