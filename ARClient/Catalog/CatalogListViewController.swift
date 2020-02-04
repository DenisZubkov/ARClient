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
        if let name = object.name,
            let _ = dataProvider.getUrlFile(fileName: name, fileExt: "usdz") {
            let previewController = QLPreviewController()
            previewController.dataSource = self
            previewController.delegate = self
            present(previewController, animated: true)
        } else {
            let url = rootViewController.objects[currentIndexPathRow].url
            dataProvider.downloadData(url: url) { data in
                if let data = data, let name = object.name {
                    let isSave = self.dataProvider.saveDataToFile(fileName: name, fileExt: "usdz", data: data)
                    print(isSave)
                    let previewController = QLPreviewController()
                    previewController.dataSource = self
                    previewController.delegate = self
                    DispatchQueue.main.async {
                        self.present(previewController, animated: true)
                    }
                }
                
            }
        }
        
        
    }
    

// MARK: - QuikPreview
    
   func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
       return 1
   }
   
   func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
    let object = rootViewController.objects[currentIndexPathRow]
    let url = dataProvider.getUrlFile(fileName: object.name!, fileExt: "usdz")!
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

}
