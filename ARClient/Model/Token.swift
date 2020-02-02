//
//  Token.swift
//  ARClient
//
//  Created by Dennis Zubkoff on 02.02.2020.
//  Copyright © 2020 Denis Zubkov. All rights reserved.
//

import Foundation

struct Token: Codable {
    let id: Int?
    let token: UUID
    let username: String
    let expiry: Date
}
