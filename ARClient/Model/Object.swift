//
//  Object.swift
//  ARClient
//
//  Created by Dennis Zubkoff on 02.02.2020.
//  Copyright © 2020 Denis Zubkov. All rights reserved.
//

import Foundation

struct Object: Codable {
    var id: Int?
    var userId: Int
    var name: String?
    var url: URL
    var serverUrl: URL?
    var date: Date
    var thumbnail: URL?
    var serverThumbnail: URL?
    var ispublic: Int?
    
    
    var internalFilename: String? {
        if let id = id {
            return "\(String(format: "%06d", userId))\(String(format: "%06d", id))"
        } else {
            return nil
        }
    }
}
