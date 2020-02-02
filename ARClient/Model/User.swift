//
//  User.swift
//  ARClient
//
//  Created by Dennis Zubkoff on 02.02.2020.
//  Copyright © 2020 Denis Zubkov. All rights reserved.
//

import Foundation

struct User: Codable {
    var id: Int?
    var username: String?
    var password: String?
    var salt: String?
    var isadmin: Int?
}
