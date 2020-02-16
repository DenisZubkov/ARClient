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
import QuickLookThumbnailing

class DataProvider: NSObject {

    let gs = GlobalSettings()
    var downloadTask: URLSessionDownloadTask!
    var fileLocation: ((URL) -> ())?
    var onProgress: ((Double) -> ())?
    var password: String?
    var login: String?
    
    private lazy var bgSession: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "ru.denzu.ARClient")
        config.isDiscretionary = true
        config.sessionSendsLaunchEvents = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    func startDownload(url: URL?) {
        if let url = url {
            let request = getRequest(method: .get, url: url, body: nil)
            downloadTask = bgSession.downloadTask(with: request)
            downloadTask.earliestBeginDate = Date().addingTimeInterval(1)
            downloadTask.countOfBytesClientExpectsToSend = 512
            downloadTask.countOfBytesClientExpectsToReceive = 100 * 1024 * 1024 // 100MB
            downloadTask.resume()
        }
    }
    
    func stopDownload() {
        downloadTask.cancel()
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            guard
                let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                let completionHandler = appDelegate.bgSessionCompletionHandler
                else { return }
            
            appDelegate.bgSessionCompletionHandler = nil
            completionHandler()
        }
    }
    
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
    
    func getRequest(method: httpMethod, url: URL, body: Data?) -> URLRequest {
        var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 10)
        guard let login = self.login, let password = self.password else { return request }
        let loginString = NSString(format: "%@:%@", login, password)
        let loginData: NSData = loginString.data(using: String.Encoding.utf8.rawValue)! as NSData
        let base64LoginString = loginData.base64EncodedString(options: NSData.Base64EncodingOptions())
        let parameters = ["Authorization": "Basic \(base64LoginString)",
            "Accept-Encoding": "gzip, deflate",
            "User-Agent": "okhttp/3.0.1"]
        request.httpMethod = method.rawValue
        request.timeoutInterval = 10
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        for parameter in parameters {
            request.addValue(parameter.value, forHTTPHeaderField: parameter.key)
        }
        if let body = body {
            request.httpBody = body
        }
        return request
    }
    
    func runRequest(method: httpMethod, url: URL, body: Data?, completion: @escaping (Data?) -> Void) {
        let request = getRequest(method: method, url: url, body: body)
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
            if response.statusCode != method.statusCode {
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

    
    func downloadPublicData(url: URL, completion: @escaping (Data?) -> Void) {
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
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            DispatchQueue.main.async {
                completion(data)
            }
        }
        dataTask.resume()
        
    }
    
    func generateThumbnailRepresentations(url: URL, completion: @escaping (UIImage?) -> Void) {
        
        // Set up the parameters of the request.
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        
        let size: CGSize = CGSize(width: 90, height: 90)
        let scale = UIScreen.main.scale
        
        // Create the thumbnail request.
        let request = QLThumbnailGenerator.Request(fileAt: url,
                                                   size: size,
                                                   scale: scale,
                                                   representationTypes: .all)
        
        // Retrieve the singleton instance of the thumbnail generator and generate the thumbnails.
        let generator = QLThumbnailGenerator.shared
        generator.generateRepresentations(for: request) { (thumbnail, type, error) in
            DispatchQueue.main.async {
                guard let thumbnail = thumbnail else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                completion(UIImage(cgImage: thumbnail.cgImage))
                
            }
        }
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

// MARK: - URLSessionDownloadDelegate

extension DataProvider: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("Did finish downloading: \(location.absoluteString)")
        guard let url = downloadTask.originalRequest?.url else { return }
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsPath.appendingPathComponent(url.lastPathComponent)
        // delete original copy
        try? FileManager.default.removeItem(at: destinationURL)
        // copy from temp to Document
        do {
            try FileManager.default.copyItem(at: location, to: destinationURL)
        } catch let error {
            print("Copy Error: \(error.localizedDescription)")
        }
        DispatchQueue.main.async {
            self.fileLocation?(destinationURL)
            
        }
    }
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        
        guard totalBytesExpectedToWrite != NSURLSessionTransferSizeUnknown else { return }
        
        let progress = Double(Double(totalBytesWritten)/Double(totalBytesExpectedToWrite))
        print("Download progress: \(progress)")
        DispatchQueue.main.async {
            self.onProgress?(progress)
        }
    }
}
