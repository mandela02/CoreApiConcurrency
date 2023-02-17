//
//  CustomError.swift
//  CoreApi
//
//  Created by TriBQ on 26/08/2022.
//

import Foundation

public enum CustomError: LocalizedError {
    case thrownError(Error)
    case customError(String)
    case serverMessage(String)
    case noInternet
    case expiredToken
    case invalidURL
    case invalidInput
    case serverError
    case noData
    case badData
    case unknownError
    case notAvailable
}
