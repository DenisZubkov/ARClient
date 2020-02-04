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
    
    func downloadPhoto(url: URL, completion: @escaping (UIImage?) -> Void) {
        let request = URLRequest(url: url)
        let dataTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            
            guard error == nil,
                data != nil,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                let _ = self else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
            }
            guard let data = data else { return }
             guard let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            DispatchQueue.main.async {
                completion(image)
            }
        }
        dataTask.resume()
        
    }

    func saveDataToFile(fileName: String, fileExt: String, data: Data) -> Bool{
        let DocumentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let fileURL = DocumentDirURL.appendingPathComponent(fileName).appendingPathExtension(fileExt)
        do {
            try data.write(to: fileURL)
            return true
        } catch {
            return false
        }
    }
    
    func getUrlFile(fileName: String, fileExt: String) -> URL? {
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
        let paths               = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        if let dirPath          = paths.first
        {
            let url = URL(fileURLWithPath: dirPath).appendingPathComponent("\(fileName).\(fileExt)")
            return url
        }
        return nil
    }
}
