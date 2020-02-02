//
//  GlobalSettings.swift
//  ARClient
//
//  Created by Dennis Zubkoff on 02.02.2020.
//  Copyright © 2020 Denis Zubkov. All rights reserved.
//

import Foundation
import UIKit

class GlobalSettings {
    
    let scheme = "http"
    let host = "localhost"
    let port = 8088
    let checkPath = "/check"
    
    
    func getUrlComponents(path: String) -> URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.port = port
        urlComponents.path = path
        return urlComponents
    }
    
    
}
