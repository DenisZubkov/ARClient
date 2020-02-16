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
    
    
     override func viewDidLoad() {
           super.viewDidLoad()
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
            rootViewController.getPublicObjectsFromWbeb(tableView: nil, collectionView: objectCollectionView)
        } else {
            rootViewController.getUsersFromWeb(tableView: nil, collectionView: objectCollectionView)
            rootViewController.getObjectsFromWbeb(tableView: nil, collectionView: objectCollectionView)
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
            self.viewObject()
            
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
          let url = dataProvider.getUrlFile(fileName: name, fileExt: "usdz") {
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
}
