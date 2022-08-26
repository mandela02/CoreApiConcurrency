//
//  File.swift
//  
//
//  Created by TriBQ on 27/08/2022.
//

import Foundation

public class KeychainManager {

    public static let shared = KeychainManager()

    public func saveToken(token: String) throws {
        let token = token.data(using: String.Encoding.utf8)!
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecValueData as String: token]

        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            if let error = SecCopyErrorMessageString(status, nil) {
                throw CustomError.customError("Error while saving to keychain: \(error)")

            }
            return
        }
        print("Successfully saved in Keychain")
    }

    public func retrieveToken() throws -> String? {
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecReturnData as String: true]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        guard status == errSecSuccess else {
            if let error = SecCopyErrorMessageString(status, nil) {
                throw CustomError.customError("Error while retrieving token from keychain: \(error)")
            }
            return nil
        }

        guard let retrievedData = dataTypeRef as? Data, let token = String(data: retrievedData, encoding: .utf8) else {
            throw CustomError.expiredToken
        }
        return token
    }

    public func removeToken() throws {
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecReturnData as String: true]
        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess else {
            if let error = SecCopyErrorMessageString(status, nil) {
                throw CustomError.customError("Error while deleting from keychain: \(error)")
            }
            return
        }
        print("Successfully deleted token from Keychain")
    }
}
