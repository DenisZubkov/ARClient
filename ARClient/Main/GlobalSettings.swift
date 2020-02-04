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
    let host = "10.0.1.7" //10.5.112.7"
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
