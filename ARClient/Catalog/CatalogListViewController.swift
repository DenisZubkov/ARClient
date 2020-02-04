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
    var currentIndexPathRow = 0
    var alert: UIAlertController!
    
    @IBOutlet weak var catalogTableView: UITableView!
    
    
    override func viewDidLoad() {
           super.viewDidLoad()
           
           // Do any additional setup after loading the view.
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
        cell.urlTextView.text = object.url.absoluteString
        if let user = rootViewController.users.filter({$0.id == object.userId}).first {
            cell.userLabel.text = user.username
        }
        if let url = object.thumbnail {
            dataProvider.downloadData(url: url) { data in
                if let data = data {
                    cell.thumbnailImageView.image = UIImage(data: data)
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentIndexPathRow = indexPath.row
        let object = rootViewController.objects[currentIndexPathRow]
        let fileManager = FileManager.default
        if let name = object.name,
            let url = dataProvider.getUrlFile(fileName: "test", fileExt: "usdz"),
            fileManager.fileExists(atPath: url.absoluteString){
            
             
                let previewController = QLPreviewController()
                previewController.dataSource = self
                previewController.delegate = self
                present(previewController, animated: true)
            
        } else {
            let url = rootViewController.objects[currentIndexPathRow].url
            dataProvider.startDownload(url: url)
            showDownloadng()
//            dataProvider.downloadData(url: url) { data in
//                if let data = data, let name = object.name {
//                    let isSave = self.dataProvider.saveDataToFile(fileName: name, fileExt: "usdz", data: data)
//                    print(isSave)
//                    let previewController = QLPreviewController()
//                    previewController.dataSource = self
//                    previewController.delegate = self
//                    DispatchQueue.main.async {
//                        self.present(previewController, animated: true)
//                    }
//                }
//
//            }
        }
        
        
    }
    

// MARK: - QuikPreview
    
   func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
       return 1
   }
   
   func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
    let object = rootViewController.objects[currentIndexPathRow]
    let url = dataProvider.getUrlFile(fileName: "test", fileExt: "usdz")!
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
