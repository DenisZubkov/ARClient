//
//  ObjectCarucelViewController.swift
//  ARClient
//
//  Created by Dennis Zubkoff on 16.02.2020.
//  Copyright © 2020 Denis Zubkov. All rights reserved.
//

import UIKit
import QuickLook

class ObjectCarucelViewController: UIViewController, QLPreviewControllerDelegate, QLPreviewControllerDataSource {

    
    let gs = GlobalSettings()
    let rootViewController = AppDelegate.shared.rootViewController
    let dataProvider = DataProvider()
    var currentObject: Object?
    let fileManager = FileManager.default
    
    private var objectCollectionView = ObjectCollectionView()
    var alert: UIAlertController!
    
    
    
     override func viewDidLoad() {
           super.viewDidLoad()
           saveFile()
           // Do any additional setup after loading the view, typically from a nib.
           
           view.addSubview(objectCollectionView)
           
           objectCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
           objectCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
           objectCollectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
           objectCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 10).isActive = true
           objectCollectionView.mainViewController = self
       }
       
    override func viewDidAppear(_ animated: Bool) {
        if rootViewController.initialTBCViewControllers == nil {
            rootViewController.initialTBCViewControllers = tabBarController?.viewControllers
        }
        
        if rootViewController.currentUser == nil {
            rootViewController.getPublicObjectsFromWeb(tableView: nil, collectionView: objectCollectionView)
        } else {
            rootViewController.getUsersFromWeb(tableView: nil, collectionView: objectCollectionView)
            if rootViewController.currentUser.isadmin == 1 {
                rootViewController.getObjectsFromWeb(tableView: nil, collectionView: objectCollectionView)
            } else {
                rootViewController.getUserObjectsFromWeb(user: rootViewController.currentUser, tableView: nil, collectionView: objectCollectionView)
            }
            
        }
        rootViewController.tabbarSetup(user: rootViewController.currentUser, tbc: self.tabBarController)
        objectCollectionView.reloadData()
    }
       

    func modelActions (object: Object, indexPath: IndexPath) {
        
        let ac = UIAlertController(title:  nil, message: "Действия с моделью \(object.name ?? "")", preferredStyle: .actionSheet)
        
        let addModel = UIAlertAction(title:  "Редактировать модель", style: .default) { action in
            self.currentObject = object
            self.performSegue(withIdentifier: "ObjectDetailSegue", sender: nil)
        }
        ac.addAction(addModel)
        
        let deleteModel = UIAlertAction(title:  "Удалить модель из каталога", style: .default) { action in
            self.rootViewController.objects.remove(at: indexPath.row)
            self.objectCollectionView.deleteItems(at: [indexPath])
            self.rootViewController.deleteObjectToWeb(object: object, collectionView: self.objectCollectionView)
            self.objectCollectionView.reloadData()
        }
        ac.addAction(deleteModel)
        
        let viewModel = UIAlertAction(title:  "Посмотреть модель", style: .default) { action in
            self.currentObject = object
            guard  let name = self.currentObject?.internalFilename else { return }
            if let url = self.dataProvider.getUrlFile(fileName: name, fileExt: .usdz),
                FileManager.default.fileExists(atPath: url.path){
                self.viewObject()
                
            } else {
                let urlComponent = self.gs.getUrlComponents(path: "\(FileType.usdz.getPath)/\(name)") 
                self.dataProvider.login = self.rootViewController.currentUser.username
                self.dataProvider.password = self.rootViewController.currentUser.password
                self.dataProvider.startDownload(url: urlComponent.url)
                self.showDownloadng()
            }
        }
        ac.addAction(viewModel)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .default, handler: nil)
        ac.addAction(cancelAction)
        
        present(ac, animated: true, completion: nil)
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
        if let name = self.currentObject?.internalFilename,
            let url = dataProvider.getUrlFile(fileName: name, fileExt: .usdz) {
              return url as QLPreviewItem
      }
          let url = URL(string: "https://apple.com")!
      return url as QLPreviewItem
     }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ObjectDetailSegue" {
            let dvc = segue.destination as! ObjectDetailViewController
            dvc.object = self.currentObject
            dvc.mainCollectionView = self.objectCollectionView
        }
    }
    
    @IBAction func returnFromEditModel(unwindSegue: UIStoryboardSegue) {
     }
    
    
    // MARK: - Downloading
    
    
    private func showDownloadng() {
        
        alert = UIAlertController(title: "Загрузка...",
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
    
    func saveFile() {
        dataProvider.fileLocation = { location in
            print(location.absoluteString)
            guard let name = self.currentObject?.internalFilename else { return }
            do {
                let data = try Data(contentsOf: location)
                let objectFileJSON: ObjectFile? = self.rootViewController.getJSONObject(from: data)
                
                guard let objectFile = objectFileJSON else {
                    print("No JSON")
                    return
                }
                guard let fileData = objectFile.fileData else {
                    print("No File")
                    return
                }
                if self.dataProvider.saveDataToFile(fileName: name, fileExt: .usdz, data: fileData) {
                    self.viewObject()
                }
            } catch {
                print("No data")
            }
        }
    }
}
