//
//  ObjectCollectionView.swift
//  ARClient
//
//  Created by Dennis Zubkoff on 16.02.2020.
//  Copyright © 2020 Denis Zubkov. All rights reserved.
//

import UIKit

class ObjectCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
     let gs = GlobalSettings()
     let rootViewController = AppDelegate.shared.rootViewController
     let dataProvider = DataProvider()
     var currentLoadObject: LoadObject?
     let fileManager = FileManager.default
     var mainViewController: ObjectCarucelViewController?

     init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        super.init(frame: .zero, collectionViewLayout: layout)
        
        backgroundColor = #colorLiteral(red: 0.9589126706, green: 0.9690223336, blue: 0.9815708995, alpha: 1)
        delegate = self
        dataSource = self
        register(ObjectCollectionViewCell.self, forCellWithReuseIdentifier: ObjectCollectionViewCell.reuseId)
        
        translatesAutoresizingMaskIntoConstraints = false
        layout.minimumLineSpacing = GlobalSettings.minimumLineSpacing
        contentInset = UIEdgeInsets(top: 0, left: GlobalSettings.leftDistanceToView, bottom: 0, right: GlobalSettings.rightDistanceToView)
        
        
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rootViewController.objects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: ObjectCollectionViewCell.reuseId, for: indexPath) as! ObjectCollectionViewCell
        let object = rootViewController.objects[indexPath.row]
        cell.nameLabel.text = object.name
        cell.commentLabel.text = object.desc
        cell.sizeLabel.text = object.ispublic ?? 0 == 1 ? "Полный" : " Приватный"
        cell.localImageView.isHidden = !(rootViewController.getfileURL(object: object, fileExt: .usdz) == nil)
        if let user = rootViewController.users.filter({$0.id == object.userId}).first {
            cell.dateLabel.text = user.username
        }
        rootViewController.getFileData(object: object, fileExt: .png) { data in
            guard let data = data, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    cell.mainImageView.image = UIImage(named: "no-photo")
                }
                return
            }
            DispatchQueue.main.async {
                cell.mainImageView.image = image
            }
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: GlobalSettings.itemWidth, height: frame.height * 0.8)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let mvc =  mainViewController {
            mvc.modelActions(object: rootViewController.objects[indexPath.row], indexPath: indexPath)
            
        }
            
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
