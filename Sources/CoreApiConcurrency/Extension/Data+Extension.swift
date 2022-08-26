//
//  Data+Extension.swift
//  CoreApi
//
//  Created by TriBQ on 26/08/2022.
//

import Foundation

extension Data {
    var asString: String? { String(data: self, encoding: .utf8) }
}
