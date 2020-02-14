//
//  LoadObjectListViewController.swift
//  ARClient
//
//  Created by Dennis Zubkoff on 08.02.2020.
//  Copyright © 2020 Denis Zubkov. All rights reserved.
//

import UIKit
import QuickLook

class LoadObjectsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, QLPreviewControllerDelegate, QLPreviewControllerDataSource  {
   
    let gs = GlobalSettings()
    let rootViewController = AppDelegate.shared.rootViewController
    let dataProvider = DataProvider()
    var currentLoadObject: LoadObject?
    let fileManager = FileManager.default
    
    
    @IBOutlet weak var loadObjectsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        rootViewController.store.fetchLoadObjects()
        rootViewController.loadObjects = rootViewController.store.fetchedLoadObjects
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rootViewController.loadObjects.count
       }
       
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LoadObjectCell", for: indexPath) as! LoadObjectTableViewCell
        let loadObject = rootViewController.loadObjects[indexPath.row]
        
        cell.nameLabel.text = loadObject.name
        cell.filenameLabel.text = loadObject.filename
        cell.loadDateLabel.text = gs.getStringFrom(dateTime: loadObject.loadDate ?? Date())
        
        if let filesize = loadObject.data?.count {
            let bcf = ByteCountFormatter()
            bcf.allowedUnits = [.useMB]
            bcf.countStyle = .file
            let filesizeString = bcf.string(fromByteCount: Int64(filesize))
            cell.filesizeLabel.text = filesizeString
        }
        
        cell.commentLabel.text = loadObject.comment
        return cell
    }
        
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentLoadObject = rootViewController.loadObjects[indexPath.row]
        if let name = currentLoadObject?.name,
            let data = currentLoadObject?.data {
            let _ = dataProvider.saveDataToFile(fileName: name, fileExt: "usdz", data: data)
            if let url = dataProvider.getUrlFile(fileName: name, fileExt: "usdz"),
            fileManager.fileExists(atPath: url.path) {
                viewObject()
            }
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteItem = UIContextualAction(style: .destructive, title: "Удалить") {  (contextualAction, view, boolValue) in
            let loadObject = self.rootViewController.loadObjects[indexPath.row]
            let alert = UIAlertController(title: "Удаление модели",
                                          message:"Удалить модель \(loadObject.name ?? "")?",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                self.rootViewController.loadObjects.remove(at: indexPath.row)
                self.loadObjectsTableView.deleteRows(at: [indexPath], with: .fade)
                self.rootViewController.store.delete(loadObject: loadObject)
            }
            alert.addAction(okAction)
            let cancelAction = UIAlertAction(title: "Отменить", style: .default) { (action) in
            }
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
        
        let saveItem = UIContextualAction(style: .normal, title: "Сохранить") {  (contextualAction, view, boolValue) in
            
            let loadObject = self.rootViewController.loadObjects[indexPath.row]
            let alert = UIAlertController(title: "Сохраниение модели",
                                          message:"Сохранить модель \(loadObject.name ?? "") на сервер?",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                self.rootViewController.saveObject(from: loadObject)
                self.rootViewController.loadObjects.remove(at: indexPath.row)
                self.loadObjectsTableView.deleteRows(at: [indexPath], with: .fade)
            }
            alert.addAction(okAction)
            let cancelAction = UIAlertAction(title: "Отменить", style: .default) { (action) in
            }
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            
        }
        saveItem.backgroundColor = gs.buttonOkBgColor
        
        
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteItem, saveItem])

        return swipeActions
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
      if let name = currentLoadObject?.name,
          let url = dataProvider.getUrlFile(fileName: name, fileExt: "usdz") {
              return url as QLPreviewItem
      }
          let url = URL(string: "https://apple.com")!
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
