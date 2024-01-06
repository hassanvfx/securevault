//
//  SecureVault.swift
//  TwinChatAI
//
//  Created by Eon Fluxor on 1/4/24.
//

import CryptoKit
import Foundation
import Security

public class SecureVault {
    private var namespace = "secureVault"
    private var encryptionKey: SymmetricKey?

    public init(namespace: String? = nil) {
        self.namespace = namespace ?? self.namespace
        if let storedKey = retrieveKeyFromKeychain() {
            encryptionKey = SymmetricKey(data: storedKey)
        } else {
            let newKey = SymmetricKey(size: .bits256)
            let keyData = newKey.withUnsafeBytes { Data(Array($0)) }
            storeKeyToKeychain(keyData)
            encryptionKey = newKey
        }
    }
}

public extension SecureVault {
    func set(key: String, value: String) async {
        guard let encryptionKey = encryptionKey, let data = value.data(using: .utf8) else {
            assertionFailure("Encryption key or value is invalid")
            return
        }
        do {
            let encryptedData = try encrypt(data, using: encryptionKey)
            await write(key: key, data: encryptedData)
        } catch {
            assertionFailure("Encryption failed: \(error)")
        }
    }

    func get(key: String) async -> String? {
        guard let encryptionKey = encryptionKey else {
            assertionFailure("Encryption key not found")
            return nil
        }
        do {
            if let encryptedData = await read(key: key) {
                let decryptedData = try decrypt(encryptedData, using: encryptionKey)
                return String(data: decryptedData, encoding: .utf8)
            }
            return nil
        } catch {
            assertionFailure("Decryption failed: \(error)")
            return nil
        }
    }
}

extension SecureVault {
    func setKey(_ key: String, value: String, completion: @escaping () -> Void) {
        Task {
            await set(key: key, value: value)
            completion()
        }
    }

    func getKey(_ key: String, completion: @escaping (String?) -> Void) {
        Task {
            let result = await get(key: key)
            completion(result)
        }
    }
}

extension SecureVault {
    private func encrypt(_ data: Data, using key: SymmetricKey) throws -> Data {
        do {
            let sealedBox = try AES.GCM.seal(data, using: key)
            guard let combined = sealedBox.combined else {
                throw EncryptionError.combinedDataNil
            }
            return combined
        } catch {
            // Wrap the underlying error into our custom EncryptionError
            throw EncryptionError.encryptionFailed(error.localizedDescription)
        }
    }

    private func decrypt(_ data: Data, using key: SymmetricKey) throws -> Data {
        do {
            let box = try AES.GCM.SealedBox(combined: data)
            return try AES.GCM.open(box, using: key)
        } catch {
            // Wrap the underlying error into our custom DecryptionError
            throw DecryptionError.decryptionFailed(error.localizedDescription)
        }
    }

    private var secureFilePath: URL {
        getDocumentsDirectory().appendingPathComponent(secureFilename)
    }

    private var keychainKey: String {
        "com.secureVault.\(namespace)"
    }

    private var secureFilename: String {
        "\(namespace).db"
    }

    private func storeKeyToKeychain(_ data: Data) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keychainKey,
            kSecValueData as String: data,
        ]
        SecItemAdd(query as CFDictionary, nil)
    }

    private func retrieveKeyFromKeychain() -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keychainKey,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var item: CFTypeRef?
        if SecItemCopyMatching(query as CFDictionary, &item) == noErr {
            return (item as? Data)
        }
        return nil
    }

    private func dataStore() -> EncryptedStore {
        guard let encryptionKey else {
            assertionFailure()
            return EncryptedStore(store: [:])
        }
        let filePath = secureFilePath
        do {
            let data = try Data(contentsOf: filePath)
            let decryptedData = try decrypt(data, using: encryptionKey)
            let store = try JSONDecoder().decode(EncryptedStore.self, from: decryptedData)
            return store
        } catch {
            print("Failed to red from disk: \(error)")
            return EncryptedStore(store: [:])
        }
    }

    @discardableResult
    private func write(key: String, data: Data) async -> Bool {
        guard let encryptionKey else {
            assertionFailure()
            return false
        }
        
        let filePath = secureFilePath
        var dataStore = dataStore()
        dataStore.store[key] = data
        do {
            let encodedData = try JSONEncoder().encode(dataStore)
            let encryptedData = try encrypt(encodedData, using: encryptionKey)
            try encryptedData.write(to: filePath)
            return true
        } catch {
            print("Failed to write to disk: \(error)")
            return false
        }
    }

    private func read(key: String) async -> Data? {
        dataStore().store[key]
    }

    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
