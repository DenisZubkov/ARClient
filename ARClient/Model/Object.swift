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
    var url: URL
    var date: Date
    var ispublic: Int?
}
