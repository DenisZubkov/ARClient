//
//  LoadObjectCollectionViewCell.swift
//  ARClient
//
//  Created by Dennis Zubkoff on 15.02.2020.
//  Copyright © 2020 Denis Zubkov. All rights reserved.
//

import UIKit

class LoadObjectCollectionViewCell: UICollectionViewCell {
    
    static let reuseId = "LoadObjectCollectionViewCell"
    
    let mainImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "no-photo")
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = #colorLiteral(red: 0.007841579616, green: 0.007844132371, blue: 0.007841020823, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let commentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let sizeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(mainImageView)
        addSubview(nameLabel)
        addSubview(commentLabel)
        addSubview(sizeLabel)
        addSubview(dateLabel)
        
        backgroundColor = .white
        
        // mainImageView constraints
        mainImageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        mainImageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        mainImageView.topAnchor.constraint(equalTo: topAnchor, constant: 40).isActive = true
        mainImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 3/5).isActive = true
        
        // nameLabel constraints
        nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: mainImageView.bottomAnchor, constant: 12).isActive = true
        
        // commentLabel constraints
        commentLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        commentLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        commentLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1/2, constant: 10).isActive = true
        
        // sizeLabel constraints
        sizeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        sizeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
        sizeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        sizeLabel.heightAnchor.constraint(equalToConstant: 14).isActive = true
        
        // dateLabel constraints
        dateLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        dateLabel.centerYAnchor.constraint(equalTo: sizeLabel.centerYAnchor).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = 5
        self.layer.shadowRadius = 9
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 5, height: 8)
        
        self.clipsToBounds = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

