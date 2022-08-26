//
//  ApiWrapper.swift
//  CoreApi
//
//  Created by TriBQ on 25/08/2022.
//

import Foundation

public class ApiRepository<T: Codable>: ApiRepositoryProtocol {
    private let endPoint: String
    
    private let scheme: String = "https"
    
    public init(_ endPoint: String) {
        self.endPoint = endPoint
    }
        
    public func fetchItem<P: Codable>(path: String,
                                      param: P) async throws -> T {
        guard Connectivity.isConnectedToInternet else {
            throw CustomError.noInternet
        }
        
        let request = try createGetRequest(from: path,
                                           method: .get,
                                           param: param)
        do {
            let result = try await URLSession.shared.data(for: request)
            
            let response = result.1
            let data = result.0
            
            try handleStatusCode(from: response)
            
            let decodedObject: T = try decode(from: data)
            return decodedObject
        } catch let error {
            if error is CustomError {
                throw error
            } else {
                throw CustomError.serverError
            }
        }
    }
    
    public func fetchItems<P: Codable>(path: String,
                                       param: P) async throws -> [T] {
        
        guard Connectivity.isConnectedToInternet else {
            throw CustomError.noInternet
        }
        
        let request = try createGetRequest(from: path,
                                           method: .get,
                                           param: param)
        do {
            let result = try await URLSession.shared.data(for: request)
            
            let response = result.1
            let data = result.0
            
            try handleStatusCode(from: response)
            
            let decodedObject: [T] = try decode(from: data)
            return decodedObject
        } catch let error {
            if error is CustomError {
                throw error
            } else {
                throw CustomError.serverError
            }
        }
    }
    
    public func postItem<P: Codable>(path: String,
                                     parameters: P) async throws -> [T] {
        
        guard Connectivity.isConnectedToInternet else {
            throw CustomError.noInternet
        }
        
        let request = try createPostRequest(from: path,
                                            method: .post,
                                            parameters: parameters)
        do {
            let result = try await URLSession.shared.data(for: request)
            
            let response = result.1
            let data = result.0
            
            try handleStatusCode(from: response)
            
            let decodedObject: [T] = try decode(from: data)
            return decodedObject
        } catch let error {
            if error is CustomError {
                throw error
            } else {
                throw CustomError.serverError
            }
        }
    }
    
    public func patchItem<P: Codable>(path: String,
                                      parameters: P) async throws -> T {
        
        guard Connectivity.isConnectedToInternet else {
            throw CustomError.noInternet
        }
        
        let request = try createPostRequest(from: path,
                                            method: .patch,
                                            parameters: parameters)
        do {
            let result = try await URLSession.shared.data(for: request)
            
            let response = result.1
            let data = result.0
            
            try handleStatusCode(from: response)
            
            let decodedObject: T = try decode(from: data)
            return decodedObject
        } catch let error {
            if error is CustomError {
                throw error
            } else {
                throw CustomError.serverError
            }
        }
    }
    
    public func putItem<P: Codable>(path: String,
                                    parameters: P) async throws -> T {
        
        guard Connectivity.isConnectedToInternet else {
            throw CustomError.noInternet
        }
        
        let request = try createPostRequest(from: path,
                                            method: .put,
                                            parameters: parameters)
        do {
            let result = try await URLSession.shared.data(for: request)
            
            let response = result.1
            let data = result.0
            
            try handleStatusCode(from: response)
            
            let decodedObject: T = try decode(from: data)
            return decodedObject
        } catch let error {
            if error is CustomError {
                throw error
            } else {
                throw CustomError.serverError
            }
        }
    }
    
    public func deleteItem(path: String) async throws -> T {
        guard Connectivity.isConnectedToInternet else {
            throw CustomError.noInternet
        }
        
        let request = try createRequest(from: path,
                                        method: .delete)
        
        do {
            let result = try await URLSession.shared.data(for: request)
            
            let response = result.1
            let data = result.0
            
            try handleStatusCode(from: response)
            
            let decodedObject: T = try decode(from: data)
            return decodedObject
        } catch let error {
            if error is CustomError {
                throw error
            } else {
                throw CustomError.serverError
            }
        }
    }
}

extension ApiRepository {
    private func handleStatusCode(from response: URLResponse) throws {
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
            throw CustomError.serverError
        }
        
        if statusCode == 500 {
            throw CustomError.serverError
        }
        
        if statusCode < 300 {
            throw CustomError.serverError
        }
    }
    
    private func decode<T: Codable>(from data: Data) throws -> T {
        do {
            let decodedObject = try JSONDecoder().decode(T.self, from: data)
            return decodedObject
        } catch let DecodingError.dataCorrupted(context) {
            throw CustomError.customError("\(context.debugDescription) at \(context.codingPath)")
        } catch let DecodingError.keyNotFound(key, context) {
            throw CustomError.customError("Key '\(key)' not found: \(context.debugDescription) at \(context.codingPath)")
        } catch let DecodingError.valueNotFound(value, context) {
            throw CustomError.customError("Value '\(value)' not found: \(context.debugDescription) at \(context.codingPath)")
        } catch let DecodingError.typeMismatch(type, context)  {
            throw CustomError.customError("Type '\(type)' mismatch: \(context.debugDescription) at \(context.codingPath)")
        } catch {
            throw CustomError.badData
        }
    }
    
    private func createGetRequest<Q: Codable>(from path: String,
                                              method: HTTPMethod,
                                              param: Q) throws -> URLRequest {
        
        var components = URLComponents()
        components.scheme = scheme
        components.host = endPoint
        components.path = path
        
        components.queryItems = try? param.asDictionary()
            .map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        
        guard let safeURL = components.url else {
            throw CustomError.badData
        }
        
        // Form the URL request
        var request = URLRequest(url: safeURL, timeoutInterval: 20.0)
        
        // Specify the http method and allow JSON returns
        request.httpMethod = method.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        
        // Add the authorization token if provided
        if let authToken = try KeychainManager.shared.retrieveToken() {
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        
        // Return the result
        return request
    }
    
    private func createPostRequest<Q: Codable>(from path: String,
                                               method: HTTPMethod,
                                               parameters: Q) throws -> URLRequest {
        
        var components = URLComponents()
        components.scheme = scheme
        components.host = endPoint
        components.path = path
        
        
        guard let safeURL = components.url else {
            throw CustomError.badData
        }
        
        // Form the URL request
        var request = URLRequest(url: safeURL, timeoutInterval: 20.0)
        
        if let parameters = parameters.toJSONString() {
            request.addData(jsonString: parameters)
        }
        
        // Specify the http method and allow JSON returns
        request.httpMethod = method.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        
        // Add the authorization token if provided
        if let authToken = try KeychainManager.shared.retrieveToken() {
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        
        // Return the result
        return request
    }
    
    private func createRequest(from path: String,
                               method: HTTPMethod) throws -> URLRequest {
        
        var components = URLComponents()
        components.scheme = scheme
        components.host = endPoint
        components.path = path
        
        guard let safeURL = components.url else {
            throw CustomError.badData
        }
        
        // Form the URL request
        var request = URLRequest(url: safeURL, timeoutInterval: 20.0)
        
        // Specify the http method and allow JSON returns
        request.httpMethod = method.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        
        // Add the authorization token if provided
        if let authToken = try KeychainManager.shared.retrieveToken() {
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        
        // Return the result
        return request
    }
}
