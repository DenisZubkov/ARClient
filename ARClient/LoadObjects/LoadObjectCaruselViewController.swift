//
//  LoadObjectCaruselViewController.swift
//  ARClient
//
//  Created by Dennis Zubkoff on 15.02.2020.
//  Copyright © 2020 Denis Zubkov. All rights reserved.
//

import UIKit
import QuickLook

class LoadObjectCaruselViewController: UIViewController, QLPreviewControllerDelegate, QLPreviewControllerDataSource  {

    let gs = GlobalSettings()
    let rootViewController = AppDelegate.shared.rootViewController
    let dataProvider = DataProvider()
    var currentLoadObject: LoadObject?
    let fileManager = FileManager.default
    
    private var loadObjectCollectionView = LoadObjectCollectionView()
    
    @IBAction func refreshDataBarButtonItem(_ sender: UIBarButtonItem) {
        rootViewController.store.fetchLoadObjects()
        rootViewController.loadObjects = rootViewController.store.fetchedLoadObjects
        loadObjectCollectionView.set(cells: rootViewController.loadObjects)
        loadObjectCollectionView.reloadData()
        tabBarController?.tabBar.items?[1].badgeValue = gs.getStringForBadgeFrom(int: rootViewController.loadObjects.count)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.addSubview(loadObjectCollectionView)
        
        loadObjectCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        loadObjectCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        loadObjectCollectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        loadObjectCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 10).isActive = true
        loadObjectCollectionView.set(cells: rootViewController.loadObjects)
        loadObjectCollectionView.mainViewController = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        rootViewController.store.fetchLoadObjects()
        rootViewController.loadObjects = rootViewController.store.fetchedLoadObjects
        loadObjectCollectionView.set(cells: rootViewController.loadObjects)
        loadObjectCollectionView.reloadData()
        tabBarController?.tabBar.items?[1].badgeValue = gs.getStringForBadgeFrom(int: rootViewController.loadObjects.count)
    }
    
    
    func modelActions (loadObject: LoadObject, indexPath: IndexPath) {
        let ac = UIAlertController(title:  nil, message: "Действия с моделью \(loadObject.name ?? "")", preferredStyle: .actionSheet)
        let addModel = UIAlertAction(title:  "Добавить модель в каталог", style: .default) { action in
            self.rootViewController.saveObject(from: loadObject)
            self.rootViewController.loadObjects.remove(at: indexPath.row)
            self.loadObjectCollectionView.deleteItems(at: [indexPath])
            self.loadObjectCollectionView.cells = self.rootViewController.loadObjects
            self.loadObjectCollectionView.reloadData()
            self.tabBarController?.tabBar.items?[1].badgeValue = self.gs.getStringForBadgeFrom(int: self.rootViewController.loadObjects.count)
        }
        ac.addAction(addModel)
        let deleteModel = UIAlertAction(title:  "Удалить модель из галереи", style: .default) { action in
            self.rootViewController.loadObjects.remove(at: indexPath.row)
            self.loadObjectCollectionView.deleteItems(at: [indexPath])
            self.rootViewController.store.delete(loadObject: loadObject)
            self.loadObjectCollectionView.cells = self.rootViewController.loadObjects
            self.loadObjectCollectionView.reloadData()
            self.tabBarController?.tabBar.items?[1].badgeValue = self.gs.getStringForBadgeFrom(int: self.rootViewController.loadObjects.count)
            
        }
        ac.addAction(deleteModel)
        let viewModel = UIAlertAction(title:  "Посмотреть модель", style: .default) { action in
            self.currentLoadObject = loadObject
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
      if let name = currentLoadObject?.name,
        let url = dataProvider.getUrlFile(fileName: name, fileExt: .usdz) {
              return url as QLPreviewItem
      }
          let url = URL(string: "https://apple.com")!
      return url as QLPreviewItem
     }
}
