//
//  Connectivity.swift
//  CoreApi
//
//  Created by TriBQ on 26/08/2022.
//

import Foundation
import Alamofire

struct Connectivity {
  static let sharedInstance = NetworkReachabilityManager()
    
  static var isConnectedToInternet:Bool {
      if let sharedInstance = sharedInstance {
          return sharedInstance.isReachable
      }
      return false
    }
}
