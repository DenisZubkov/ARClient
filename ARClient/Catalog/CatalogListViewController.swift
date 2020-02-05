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
            print(location.absoluteString)
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
        saveFile()
    }
       
    override func viewDidAppear(_ animated: Bool) {
        rootViewController.loadObjectsFromWbeb(tableView: catalogTableView)
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
        if let url = object.thumbnail {
            dataProvider.downloadData(url: url) { data in
                if let data = data {
                    cell.thumbnailImageView.image = UIImage(data: data)
                }
            }
        }
        cell.isServerLoadView.layer.cornerRadius = 8
        cell.isServerLoadView.layer.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        cell.isServerLoadView.layer.borderWidth = 1
        cell.isAppLoadView.layer.cornerRadius = 8
        cell.isAppLoadView.layer.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        cell.isAppLoadView.layer.borderWidth = 1
        if let name = object.name,
            let url = dataProvider.getUrlFile(fileName: name, fileExt: "usdz"),
            fileManager.fileExists(atPath: url.path){
            cell.isAppLoadView.backgroundColor = UIColor.green
        } else {
            cell.isAppLoadView.backgroundColor = UIColor.red
        }
        if let name = object.name {
            cell.isServerLoadView.backgroundColor = UIColor.red
        } else {
            cell.isServerLoadView.backgroundColor = UIColor.green
        }
            
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentObject = rootViewController.objects[indexPath.row]
        if let name = currentObject?.name,
            let url = dataProvider.getUrlFile(fileName: name, fileExt: "usdz"),
            fileManager.fileExists(atPath: url.path){
            viewObject()
            
        } else {
            guard let url = currentObject?.url else { return }
            dataProvider.startDownload(url: url)
            showDownloadng()
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
    let name  = self.currentObject?.name ?? "no_model"
    let url = dataProvider.getUrlFile(fileName: name, fileExt: "usdz")!
    return url as QLPreviewItem
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
