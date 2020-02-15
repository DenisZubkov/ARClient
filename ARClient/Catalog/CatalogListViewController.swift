//
//  CatalogListViewController.swift
//  ARClient
//
//  Created by Dennis Zubkoff on 02.02.2020.
//  Copyright © 2020 Denis Zubkov. All rights reserved.
//

import UIKit
import QuickLook

class CatalogListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,
QLPreviewControllerDelegate, QLPreviewControllerDataSource {
    
    
    
    let gs = GlobalSettings()
    let rootViewController = AppDelegate.shared.rootViewController
    let dataProvider = DataProvider()
    var currentObject: Object?
    var alert: UIAlertController!
    let fileManager = FileManager.default
    
    @IBOutlet weak var catalogTableView: UITableView!
    
    func saveFile() {
        dataProvider.fileLocation = { location in
            guard let name = self.currentObject?.name else { return }
            let DocumentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileURL = DocumentDirURL.appendingPathComponent(name).appendingPathExtension("usdz")
            // delete original copy
            try? FileManager.default.removeItem(at: fileURL)
            // copy from temp to Document
            do {
                try FileManager.default.copyItem(at: location, to: fileURL)
                self.viewObject()
                print("File exist? : \(FileManager.default.fileExists(atPath: fileURL.path))")
            } catch let error {
                print("Copy Error: \(error.localizedDescription)")
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // saveFile()
        
    }
       
    override func viewDidAppear(_ animated: Bool) {
        if rootViewController.initialTBCViewControllers == nil {
            rootViewController.initialTBCViewControllers = tabBarController?.viewControllers
        }
       
        if rootViewController.currentUser == nil {
            rootViewController.getPublicObjectsFromWbeb(tableView: catalogTableView)
        } else {
            rootViewController.getUsersFromWeb(tableView: catalogTableView)
            rootViewController.getObjectsFromWbeb(tableView: catalogTableView)
        }
        rootViewController.tabbarSetup(user: rootViewController.currentUser, tbc: self.tabBarController)
        catalogTableView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rootViewController.objects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CatalogCell", for: indexPath) as! CatalogListTableViewCell
        let object = rootViewController.objects[indexPath.row]
        cell.nameLabel.text = object.name
        cell.isPublicLabel.text = object.ispublic ?? 0 == 1 ? "Полный" : " Приватный"
        if let user = rootViewController.users.filter({$0.id == object.userId}).first {
            cell.userLabel.text = user.username
        }
        cell.thumbnailImageView.layer.cornerRadius = 44
        cell.thumbnailImageView.layer.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        cell.thumbnailImageView.layer.borderWidth = 2
        
        cell.isServerLoadView.layer.cornerRadius = 8
        cell.isServerLoadView.layer.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        cell.isServerLoadView.layer.borderWidth = 1
        cell.isAppLoadView.layer.cornerRadius = 8
        cell.isAppLoadView.layer.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        cell.isAppLoadView.layer.borderWidth = 1
        if let name = object.internalFilename,
            let url = dataProvider.getUrlFile(fileName: name, fileExt: "usdz"),
            fileManager.fileExists(atPath: url.path) {
            
            cell.isAppLoadView.backgroundColor = UIColor.green
            dataProvider.generateThumbnailRepresentations(url: url) { image in
                if let image = image {
                    cell.thumbnailImageView.image = image
                } else {
                    cell.thumbnailImageView.image = UIImage(named: "no-photo")
                }
            }
            
        } else {
            rootViewController.getFileFromWeb(object: object) { data in
                guard let _ = data else {
                    DispatchQueue.main.async {
                        cell.thumbnailImageView.image = UIImage(named: "no-photo")
                    }
                    return
                }
                if let name = object.internalFilename,
                    let url = self.dataProvider.getUrlFile(fileName: name, fileExt: "usdz"),
                    self.fileManager.fileExists(atPath: url.path) {
                    
                    cell.isAppLoadView.backgroundColor = UIColor.green
                    self.dataProvider.generateThumbnailRepresentations(url: url) { image in
                        DispatchQueue.main.async {
                            if let image = image {
                                cell.thumbnailImageView.image = image
                            } else {
                                cell.thumbnailImageView.image = UIImage(named: "no-photo")
                            }
                        }
                    }
                    
                }
            }
        }
        if let _ = object.name {
            cell.isServerLoadView.backgroundColor = UIColor.red
        } else {
            cell.isServerLoadView.backgroundColor = UIColor.green
        }
            
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentObject = rootViewController.objects[indexPath.row]
        guard let name = currentObject?.internalFilename else {
                guard let url = currentObject?.url else { return }
                dataProvider.startDownload(url: url)
                showDownloadng()
                return
        }
        if let url = dataProvider.getUrlFile(fileName: name, fileExt: "usdz"),
            fileManager.fileExists(atPath: url.path) {
            viewObject()
        } else {
            guard let filePath = currentObject?.serverUrl else { return }
            let urlComponent = gs.getUrlComponents(path: "/file\(filePath)")
            guard let url = urlComponent.url else { return }
            dataProvider.login = rootViewController.currentUser.username
            dataProvider.password = rootViewController.currentUser.password
            dataProvider.runRequest(method: .get, url: url, body: nil) { data in
                guard let data = data else { return }
                //UserDefaults.standard.set(data, forKey: url.absoluteString)
                let objectFileJSON: ObjectFile? = self.rootViewController.getJSONObject(from: data)
                guard let objectFile = objectFileJSON else { return }
                guard let dataFile = objectFile.data else { return }
                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let destinationURL = documentsPath.appendingPathComponent(name).appendingPathExtension("usdz")
                try? FileManager.default.removeItem(at: destinationURL)
                do {
                    try dataFile.write(to: destinationURL)
                } catch let error {
                    print("Write Data Error: \(error.localizedDescription)")
                }
            }
        }
        
        
    }
    

// MARK: - QuikPreview
    
    func viewObject() {
        let previewController = QLPreviewController()
        previewController.dataSource = self
        previewController.delegate = self
        previewController.navigationItem.rightBarButtonItems = []
        self.present(previewController, animated: true)
    }
    
   func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
       return 1
   }
   
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        
        if let name = currentObject?.internalFilename,
            let url = dataProvider.getUrlFile(fileName: name, fileExt: "usdz") {
            return url as QLPreviewItem
        } else {
            let url = URL(string: "https://apple.com")!
            return url as QLPreviewItem
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */



// MARK: - Downloading progress

    private func showDownloadng() {
        
        alert = UIAlertController(title: "Downloading...",
                                  message: "0%",
                                  preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (action) in
            self.dataProvider.stopDownload()
        }
        
        let hight = NSLayoutConstraint(item: alert.view!,
                                       attribute: .height,
                                       relatedBy: .equal,
                                       toItem: nil,
                                       attribute: .notAnAttribute,
                                       multiplier: 0,
                                       constant: 170)
        
        alert.view.addConstraint(hight)
        
        alert.addAction(cancelAction)
        present(alert, animated: true) {
            
            let size = CGSize(width: 40, height: 40)
            let point = CGPoint(x: self.alert.view.frame.width / 2 - size.width / 2,
                                y: self.alert.view.frame.height / 2 - size.height / 2)
            
            let activityIndicator = UIActivityIndicatorView(frame: CGRect(origin: point, size: size))
            activityIndicator.color = .gray
            activityIndicator.startAnimating()
            
            let progressView = UIProgressView(frame: CGRect(x: 0,
                                                            y: self.alert.view.frame.height - 44,
                                                            width: self.alert.view.frame.width,
                                                            height: 2))
            progressView.tintColor = .blue
            
            self.dataProvider.onProgress = { (progress) in
                progressView.progress = Float(progress)
                self.alert.message = String(Int(progress * 100)) + "%"
                
                if progressView.progress == 1 {
                    self.alert.dismiss(animated: false)
                }
            }
            
            self.alert.view.addSubview(progressView)
            self.alert.view.addSubview(activityIndicator)
        }
    }
}
