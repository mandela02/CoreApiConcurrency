//
//  URLRequest+Extension.swift
//  CoreApi
//
//  Created by TriBQ on 26/08/2022.
//

import Foundation

extension URLRequest {
    mutating func addData(jsonString: String) {
        guard let jsonData = jsonString.data(using: .utf8) else { return }
        self.httpBody = jsonData
    }
}
