//
//  LoadObjectCollectionView.swift
//  ARClient
//
//  Created by Dennis Zubkoff on 15.02.2020.
//  Copyright © 2020 Denis Zubkov. All rights reserved.
//

import UIKit

class LoadObjectCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
     let gs = GlobalSettings()
     let rootViewController = AppDelegate.shared.rootViewController
     let dataProvider = DataProvider()
     var currentLoadObject: LoadObject?
     let fileManager = FileManager.default
     var cells = [LoadObject]()
     var mainViewController: LoadObjectCaruselViewController?

     init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        super.init(frame: .zero, collectionViewLayout: layout)
        
        backgroundColor = #colorLiteral(red: 0.9589126706, green: 0.9690223336, blue: 0.9815708995, alpha: 1)
        delegate = self
        dataSource = self
        register(LoadObjectCollectionViewCell.self, forCellWithReuseIdentifier: LoadObjectCollectionViewCell.reuseId)
        
        translatesAutoresizingMaskIntoConstraints = false
        layout.minimumLineSpacing = GlobalSettings.loadObjectMinimumLineSpacing
        contentInset = UIEdgeInsets(top: 0, left: GlobalSettings.leftDistanceToView, bottom: 0, right: GlobalSettings.rightDistanceToView)
        
        
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
    }
    
    func set(cells: [LoadObject]) {
        self.cells = cells
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: LoadObjectCollectionViewCell.reuseId, for: indexPath) as! LoadObjectCollectionViewCell
        //cell.mainImageView.image = cells[indexPath.row]
        
        cell.nameLabel.text = cells[indexPath.row].name
        cell.commentLabel.text = cells[indexPath.row].comment
        cell.dateLabel.text = gs.getStringFrom(dateTime: cells[indexPath.row].loadDate ?? Date())
        if let filesize = cells[indexPath.row].data?.count {
            let bcf = ByteCountFormatter()
            bcf.allowedUnits = [.useMB]
            bcf.countStyle = .file
            let filesizeString = bcf.string(fromByteCount: Int64(filesize))
            cell.sizeLabel.text = filesizeString
        }
        
        if let name = cells[indexPath.row].name {
            if let url = dataProvider.getUrlFile(fileName: name, fileExt: "usdz"),
                fileManager.fileExists(atPath: url.path) {
                dataProvider.generateThumbnailRepresentations(url: url) { image in
                    if let image = image {
                        cell.mainImageView.image = image
                    }
                }
            } else {
                if let data = cells[indexPath.row].data {
                    if dataProvider.saveDataToFile(fileName: name, fileExt: "usdz", data: data) {
                        if let url = dataProvider.getUrlFile(fileName: name, fileExt: "usdz"),
                            fileManager.fileExists(atPath: url.path) {
                            dataProvider.generateThumbnailRepresentations(url: url) { image in
                                if let image = image {
                                    cell.mainImageView.image = image
                                } else {
                                
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: GlobalSettings.loadObjectItemWidth, height: frame.height * 0.8)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let mvc =  mainViewController {
            mvc.modelActions(loadObject: cells[indexPath.row], indexPath: indexPath)
            
        }
            
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}

