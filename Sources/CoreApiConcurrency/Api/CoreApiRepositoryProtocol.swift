//
//  CoreApiRepositoryProtocol.swift
//  CoreApi
//
//  Created by TriBQ on 26/08/2022.
//

import Foundation

public protocol ApiRepositoryProtocol {
    associatedtype T
    
    func fetchItem<P: Codable>(path: String,
                               param: P) async throws -> T
    
    func fetchItems<P: Codable>(path: String,
                                param: P) async throws -> [T]
    
    func postItem<P: Codable>(path: String,
                              parameters: P) async throws -> [T]
    
    func patchItem<P: Codable>(path: String,
                               parameters: P) async throws -> T
    
    func putItem<P: Codable>(path: String,
                             parameters: P) async throws -> T
    
    func deleteItem(path: String) async throws -> T
}

