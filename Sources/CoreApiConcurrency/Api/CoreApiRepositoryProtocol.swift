//
//  CoreApiRepositoryProtocol.swift
//  CoreApi
//
//  Created by TriBQ on 26/08/2022.
//

import Foundation

public protocol ApiRepositoryProtocol {
    associatedtype T
    
    func fetchItem(path: String,
                   param: [String: any Codable],
                   needAuthToken: Bool) async throws -> T
    
    func fetchItems(path: String,
                    param: [String: any Codable],
                    needAuthToken: Bool) async throws -> [T]
    
    func postItem(path: String,
                  parameters: [String: any Codable],
                  needAuthToken: Bool) async throws -> T
    
    func patchItem(path: String,
                   parameters: [String: any Codable],
                   needAuthToken: Bool) async throws -> T
    
    func putItem(path: String,
                 parameters: [String: any Codable],
                 needAuthToken: Bool) async throws -> T
    
    func deleteItem(path: String,
                    needAuthToken: Bool) async throws -> T
    
    func postImage(path: String,
                   imageDatas: [String: [Data]],
                   additionData: [String: any Codable],
                   needAuthToken: Bool) async throws -> T
}
