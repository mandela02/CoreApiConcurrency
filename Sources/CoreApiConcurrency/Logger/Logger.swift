//
//  Logger.swift
//
//
//  Created by TriBQ on 22/11/2022.
//

import Foundation

struct Logger {
    static func log(request: URLRequest) {

        let urlString = request.url?.absoluteString ?? ""
        let components = NSURLComponents(string: urlString)

        let method = request.httpMethod != nil ? "\(request.httpMethod!)": ""
        let path = "\(components?.path ?? "")"
        let query = "\(components?.query ?? "")"
        let host = "\(components?.host ?? "")"

        var requestLog = "\n---------- OUT ---------->\n"
        requestLog += "\(urlString)"
        requestLog += "\n\n"
        requestLog += "\(method) \(path)?\(query) HTTP/1.1\n"
        requestLog += "Host: \(host)\n"
        for (key,value) in request.allHTTPHeaderFields ?? [:] {
            requestLog += "\(key): \(value)\n"
        }
        if let body = request.httpBody{
            let bodyString = NSString(data: body, encoding: String.Encoding.utf8.rawValue) ?? "Can't render body; not utf8 encoded";
            requestLog += "\n\(bodyString)\n"
        }

        requestLog += "\n------------------------->\n";
        print(requestLog)
    }

    static  func log(data: Data?, response: URLResponse?, error: Error?) {

        let response = response as? HTTPURLResponse
        
        let urlString = response?.url?.absoluteString
        let components = NSURLComponents(string: urlString ?? "")

        let path = "\(components?.path ?? "")"
        let query = "\(components?.query ?? "")"

        var responseLog = "\n<---------- IN ----------\n"
        if let urlString = urlString {
            responseLog += "\(urlString)"
            responseLog += "\n\n"
        }

        if let statusCode = response?.statusCode {
            responseLog += "HTTP \(statusCode) \(path)?\(query)\n"
        }
        
        if let host = components?.host {
            responseLog += "Host: \(host)\n"
        }
        
        for (key,value) in response?.allHeaderFields ?? [:] {
            responseLog += "\(key): \(value)\n"
        }
        if let body = data,
           let object = try? JSONSerialization.jsonObject(with: body, options: []),
           let preatyData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
           let prettyPrintedString = NSString(data: preatyData, encoding: String.Encoding.utf8.rawValue) {
            responseLog += "\n\(prettyPrintedString)\n"
        }
        
        
        if let error = error{
            responseLog += "\nError: \(error.localizedDescription)\n"
        }
        
        responseLog += "<------------------------\n";
        print(responseLog)
    }
    
}

