//
//  SavedLocation.swift
//  UberSwiftUI
//
//  Created by Marcos Michel on 29/09/23.
//

import Firebase

struct SavedLocation: Codable {
    let title: String
    let address: String
    let coordinates: GeoPoint
}
