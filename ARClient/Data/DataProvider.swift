//
//  DataProvider.swift
//  ARClient
//
//  Created by Dennis Zubkoff on 02.02.2020.
//  Copyright © 2020 Denis Zubkov. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DataProvider {

    let gs = GlobalSettings()
    
    func check(url:URL, completion: @escaping (String?) -> Void) {
        let request = URLRequest(url: url)
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                DispatchQueue.main.async {
                    completion(error?.localizedDescription)
                }
            }
            guard data != nil else {
                DispatchQueue.main.async {
                    completion("Данные недоступны")
                }
                return
            }
            guard let response = response as? HTTPURLResponse else { return }
            if response.statusCode != 200 {
                let statusCodeString = String(response.statusCode)
                completion(statusCodeString)
                return
            }
            DispatchQueue.main.async {
                completion("Ok")
            }
        }
        dataTask.resume()
    }
    
    func downloadData(url:URL, completion: @escaping (Data?) -> Void) {
        let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 600)
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                DispatchQueue.main.async {
                    completion(error?.localizedDescription.data(using: .utf8))
                }
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            guard let response = response as? HTTPURLResponse else { return }
            if response.statusCode != 200 {
                let statusCodeString = String(response.statusCode)
                completion(statusCodeString.data(using: .utf8))
                return
            }
            //UserDefaults.standard.set(data, forKey: url.absoluteString)
            DispatchQueue.main.async {
                completion(data)
            }
        }
        dataTask.resume()
    }
    
    
    
}
