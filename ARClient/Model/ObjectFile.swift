//
//  ObjectFile.swift
//  ARClient
//
//  Created by Denis Zubkov on 13.02.2020.
//  Copyright © 2020 Denis Zubkov. All rights reserved.
//

import Foundation

struct ObjectFile: Codable {
    var filename: String?
    var fileData: Data?
    var thumbnailData: Data?
}
