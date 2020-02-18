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
    let host = "78.47.113.172" // "denzu.ru" // "10.0.1.7" //10.5.112.7"
    let port = 8088
    let checkPath = "/check"
    let authPath = "/login/basic"
    let buttonOkBgColor = #colorLiteral(red: 0, green: 0.5690457821, blue: 0.5746168494, alpha: 1)
    let buttonCancelBgColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
    let buttonOkTextColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    let buttonCancelTextColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    let buttonCornerRadius = 5
    static let leftDistanceToView: CGFloat = 40
    static let rightDistanceToView: CGFloat = 40
    static let minimumLineSpacing: CGFloat = 10
    static let itemWidth = (UIScreen.main.bounds.width - leftDistanceToView - rightDistanceToView - (minimumLineSpacing / 1.0)) / 1.0
    
    
    func getUrlComponents(path: String) -> URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.port = port
        urlComponents.path = path
        return urlComponents
    }
    
    func getStringFrom(dateTime: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy hh:mm"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 60 * 60 * 3)
        return dateFormatter.string(from: dateTime)
    }
    
    func getStringForBadgeFrom(int: Int?) -> String? {
        guard let int = int else { return nil }
        guard int != 0 else { return nil }
        return String(int)
        
    }
    
}

enum FileType: String {
    case png = "png"
    case usdz = "usdz"
    case all = "*"
    
    var valueWithDot: String {
        return ".\(self.rawValue)"
    }
    
    var getPath: String {
       switch self {
        case .png : return "/image"
        case .usdz : return "/Model"
        case .all : return "/file"
        
        }
    }
    
}

enum HttpMethod: String  {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    
    var statusCode: Int {
        switch self {
        case .get : return 200
        case .post : return 201
        case .put : return 200
        case .delete : return 200
        }
    }
}
