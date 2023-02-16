//
//  Encodeable+Extension.swift
//  CoreApi
//
//  Created by TriBQ on 26/08/2022.
//

import Foundation

extension Encodable {
    func asDictionary() throws -> [String: Any] {
      let data = try JSONEncoder().encode(self)
      guard let dictionary = try JSONSerialization
                .jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
        throw NSError()
      }
      return dictionary
    }
    
    func toJSONString(toSnakeCase: Bool = false) -> String? {
        let encoder = JSONEncoder()
        if toSnakeCase { encoder.keyEncodingStrategy = .convertToSnakeCase }
        guard let jsonData = try? encoder.encode(self) else { return nil }
        return jsonData.asString
    }
}

extension Dictionary where Key: Codable, Value: Codable {
    func jsonString(toSnakeCase: Bool = false) -> String? {
        let encoder = JSONEncoder()
        if toSnakeCase { encoder.keyEncodingStrategy = .convertToSnakeCase }
        if let jsonData = try? encoder.encode(self) {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
            return nil
        }
        return nil
    }
}

extension Dictionary {
    func jsonString(toSnakeCase: Bool = false) -> String? {
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: self,
            options: []) {
            let theJSONText = String(data: theJSONData,
                                     encoding: .ascii)
            return theJSONText
        }
        return nil
    }
}

