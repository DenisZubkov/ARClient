//
//  USDZModel.swift
//  ARLoad
//
//  Created by Denis Zubkov on 07.02.2020.
//  Copyright © 2020 Denis Zubkov. All rights reserved.
//

import QuickLookThumbnailing
import UIKit

class USDZModel {
    // MARK: - Static Properties
    static let imageUpdatedNotification = Notification.Name("USDZModel.imageUpdated")
    
    // MARK: - Stored Properties
    private let filename: String
    let url: URL
    
    var image: UIImage?
    
    // MARK: - Computed Properties
    var name: String { filename.undotted.spaced.capitalized }
    
    // MARK: - Initializers
    init?(url: URL) {
        
        filename = NSString(string: url.path).lastPathComponent
        self.url = url
        
        // try to find an image with the same name
        if let image = UIImage(named: filename.undotted) {
            self.image = image
            return
        }
        
        let size = CGSize(width: 96, height: 128)
        let scale = UIScreen.main.scale
        
        // create the thumbnail request
        guard #available(iOS 13.0, *) else { return }
        
        let request = QLThumbnailGenerator.Request(
            fileAt: url,
            size: size,
            scale: scale,
            representationTypes: .icon
        )
        
        let generator = QLThumbnailGenerator.shared
        generator.generateRepresentations(for: request) { thumbnail, type, error in
            guard let thumbnail = thumbnail else {
                if let error = error {
                    print(#line, #function, error.localizedDescription)
                } else {
                    print(#line, #function, "ERROR: Can't create thumbnail for \(url.path)")
                }
                return
            }
            
            self.image = thumbnail.uiImage
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Self.imageUpdatedNotification, object: self)
            }
        }
    }
}

// MARK: - Comparable
extension USDZModel: Comparable {
    static func < (lhs: USDZModel, rhs: USDZModel) -> Bool { lhs.name < rhs.name }
    static func == (lhs: USDZModel, rhs: USDZModel) -> Bool { lhs.name == rhs.name }
}

// MARK: - CustomStringConvertible
extension USDZModel: CustomStringConvertible {
    var description: String {
        return "\(name): \(image?.description ?? "no thumbnail")"
    }
}

extension String {
    var spaced: String { replacingOccurrences(of: "_", with: " ") }
    
    var undotted: String {
        var result = ""
        for letter in self {
            if letter == "." { break }
            result = "\(result)\(letter)"
        }
        return result
    }
}
