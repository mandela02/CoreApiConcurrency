//
//  ApiWrapper.swift
//  CoreApi
//
//  Created by TriBQ on 25/08/2022.
//

import Foundation
import Alamofire

public class ApiRepository<T: Codable>: ApiRepositoryProtocol {
    private let endPoint: String
    
    private let scheme: String = "https"
    
    public init(_ endPoint: String) {
        self.endPoint = endPoint
    }
    
    public func fetchItem(path: String,
                          param: [String: any Codable],
                          needAuthToken: Bool = true) async throws -> T {
        guard Connectivity.isConnectedToInternet else {
            throw CustomError.noInternet
        }
        
        let request = try createGetRequest(from: path,
                                           method: .get,
                                           param: param,
                                           needAuthToken: needAuthToken)
        do {
            let result = try await URLSession.shared.data(for: request)
            Logger.log(data: result.0, response: result.1, error: nil)

            let response = result.1
            let data = result.0
            
            try handleStatusCode(from: response)
            
            let decodedObject: T = try decode(from: data)
            return decodedObject
        } catch let error {
            Logger.log(data: nil, response: nil, error: error)

            if error is CustomError {
                throw error
            } else {
                throw CustomError.serverError
            }
        }
    }
    
    public func fetchItems(path: String,
                           param: [String: any Codable],
                           needAuthToken: Bool = true) async throws -> [T] {
        
        guard Connectivity.isConnectedToInternet else {
            throw CustomError.noInternet
        }
        
        let request = try createGetRequest(from: path,
                                           method: .get,
                                           param: param,
                                           needAuthToken: needAuthToken)
        do {
            let result = try await URLSession.shared.data(for: request)
            Logger.log(data: result.0, response: result.1, error: nil)

            let response = result.1
            let data = result.0
            
            try handleStatusCode(from: response)
            
            let decodedObject: [T] = try decode(from: data)
            return decodedObject
        } catch let error {
            Logger.log(data: nil, response: nil, error: error)
            if error is CustomError {
                throw error
            } else {
                throw CustomError.serverError
            }
        }
    }
    
    public func postItem(path: String,
                         parameters: [String: any Codable],
                         needAuthToken: Bool = true) async throws -> T {
        
        guard Connectivity.isConnectedToInternet else {
            throw CustomError.noInternet
        }
        
        let request = try createPostRequest(from: path,
                                            method: .post,
                                            parameters: parameters,
                                            needAuthToken: needAuthToken)
        do {
            let result = try await URLSession.shared.data(for: request)
            Logger.log(data: result.0, response: result.1, error: nil)

            let response = result.1
            let data = result.0
            
            try handleStatusCode(from: response)
            
            let decodedObject: T = try decode(from: data)
            return decodedObject
        } catch let error {
            Logger.log(data: nil, response: nil, error: error)
            if error is CustomError {
                throw error
            } else {
                throw CustomError.serverError
            }
        }
    }
    
    public func patchItem(path: String,
                          parameters: [String: any Codable],
                          needAuthToken: Bool = true) async throws -> T {
        
        guard Connectivity.isConnectedToInternet else {
            throw CustomError.noInternet
        }
        
        let request = try createPostRequest(from: path,
                                            method: .patch,
                                            parameters: parameters,
                                            needAuthToken: needAuthToken)
        do {
            let result = try await URLSession.shared.data(for: request)
            Logger.log(data: result.0, response: result.1, error: nil)
            
            let response = result.1
            let data = result.0
            
            try handleStatusCode(from: response)
            
            let decodedObject: T = try decode(from: data)
            return decodedObject
        } catch let error {
            Logger.log(data: nil, response: nil, error: error)

            if error is CustomError {
                throw error
            } else {
                throw CustomError.serverError
            }
        }
    }
    
    public func putItem(path: String,
                        parameters: [String: any Codable],
                        needAuthToken: Bool = true) async throws -> T {
        
        guard Connectivity.isConnectedToInternet else {
            throw CustomError.noInternet
        }
        
        let request = try createPostRequest(from: path,
                                            method: .put,
                                            parameters: parameters,
                                            needAuthToken: needAuthToken)
        do {
            let result = try await URLSession.shared.data(for: request)
            Logger.log(data: result.0, response: result.1, error: nil)

            let response = result.1
            let data = result.0
            
            try handleStatusCode(from: response)
            
            let decodedObject: T = try decode(from: data)
            return decodedObject
        } catch let error {
            Logger.log(data: nil, response: nil, error: error)
            if error is CustomError {
                throw error
            } else {
                throw CustomError.serverError
            }
        }
    }
    
    public func deleteItem(path: String,
                           needAuthToken: Bool = true) async throws -> T {
        guard Connectivity.isConnectedToInternet else {
            throw CustomError.noInternet
        }
        
        let request = try createRequest(from: path,
                                        method: .delete,
                                        needAuthToken: needAuthToken)
        
        do {
            let result = try await URLSession.shared.data(for: request)
            Logger.log(data: result.0, response: result.1, error: nil)

            let response = result.1
            let data = result.0
            
            try handleStatusCode(from: response)
            
            let decodedObject: T = try decode(from: data)
            return decodedObject
        } catch let error {
            Logger.log(data: nil, response: nil, error: error)
            if error is CustomError {
                throw error
            } else {
                throw CustomError.serverError
            }
        }
    }
    
    public func postImage(path: String,
                          imageDatas: [String: [Data]],
                          additionData: [String: any Codable],
                          needAuthToken: Bool = true) async throws -> T {
        guard Connectivity.isConnectedToInternet else {
            throw CustomError.noInternet
        }
        
        let url = try createUrl(from: path)
        
        var header = HTTPHeaders()
        
        if needAuthToken {
            if let authToken = try KeychainManager.shared.retrieveToken() {
                header.add(HTTPHeader(name: "Authorization", value: "Bearer \(authToken)"))
            }
        }
        

        return try await withCheckedThrowingContinuation({ continuation in
            _ = AF
                .upload(multipartFormData: { (multipartFormData) in
                    for imageData in imageDatas {
                        for image in imageData.value {
                            multipartFormData.append(image,
                                                     withName: imageData.key,
                                                     fileName: "\(UUID().uuidString).png",
                                                     mimeType: "image/png")
                        }
                    }
                    
                    for field in additionData {
                        multipartFormData.append("\(field.value)".data(using: .utf8)!,
                                                 withName: field.key)
                    }
                    
                }, to: url, headers: header)
                .response(completionHandler: { [weak self] afResponse in
                    guard let self = self else {
                        continuation.resume(throwing: CustomError.unknownError)
                        return
                    }
                    guard let response = afResponse.response else {
                        continuation.resume(throwing: CustomError.badData)
                        return
                    }

                    if let error = afResponse.error {
                        continuation.resume(throwing: CustomError.customError(error.localizedDescription))
                        return
                    }

                    guard let data = afResponse.data else {
                        continuation.resume(throwing: CustomError.badData)
                        return
                    }

                    do {
                        try self.handleStatusCode(from: response)
                        let decodedObject: T = try self.decode(from: data)

                        continuation.resume(returning: decodedObject)
                        return
                    } catch {
                        continuation.resume(throwing: error)
                        return
                    }
                })
        })
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
            return
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
    
    private func createGetRequest(from path: String,
                                  method: HTTPMethod,
                                  param: [String: any Codable],
                                  needAuthToken: Bool) throws -> URLRequest {
        
        var components = URLComponents()
        components.scheme = scheme
        components.host = endPoint
        components.path = path
        
        components.queryItems = param
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
        if needAuthToken {
            if let authToken = try KeychainManager.shared.retrieveToken() {
                request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
            }
        }
        Logger.log(request: request)
        // Return the result
        return request
    }
    
    private func createPostRequest(from path: String,
                                   method: HTTPMethod,
                                   parameters: [String: any Codable],
                                   needAuthToken: Bool) throws -> URLRequest {
        
        var components = URLComponents()
        components.scheme = scheme
        components.host = endPoint
        components.path = path
        
        
        guard let safeURL = components.url else {
            throw CustomError.badData
        }
        
        // Form the URL request
        var request = URLRequest(url: safeURL, timeoutInterval: 20.0)
        
        
        if let parameters = parameters.jsonString() {
            request.addData(jsonString: parameters)
        }
        
        // Specify the http method and allow JSON returns
        request.httpMethod = method.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        
        // Add the authorization token if provided
        if needAuthToken {
            if let authToken = try KeychainManager.shared.retrieveToken() {
                request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
            }
        }
        Logger.log(request: request)
        // Return the result
        return request
    }
    
    private func createRequest(from path: String,
                               method: HTTPMethod,
                               needAuthToken: Bool) throws -> URLRequest {
        
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
        if needAuthToken {
            if let authToken = try KeychainManager.shared.retrieveToken() {
                request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
            }
        }
        
        Logger.log(request: request)
        // Return the result
        return request
    }
    
    func createUrl(from path: String) throws -> URL {
        var components = URLComponents()
        components.scheme = scheme
        components.host = endPoint
        components.path = path
        
        guard let safeURL = components.url else {
            throw CustomError.badData
        }
        
        return safeURL
    }
}

