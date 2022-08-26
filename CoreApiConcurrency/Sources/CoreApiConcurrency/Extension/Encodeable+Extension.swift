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
