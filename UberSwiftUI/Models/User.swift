//
//  User.swift
//  UberSwiftUI
//
//  Created by Marcos Michel on 25/09/23.
//

import Firebase

enum AccountType: Int, Codable {
    case passeger
    case driver
}

struct User: Codable {
    let fullname: String
    let email: String
    let uid: String
    var coordinate: GeoPoint
    var accountType: AccountType
    var homeLocation: SavedLocation?
    var workLocation: SavedLocation?
}
