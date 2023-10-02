//
//  DeveloperPreview.swift
//  UberSwiftUI
//
//  Created by Marcos Michel on 02/10/23.
//

import SwiftUI
import Firebase

extension PreviewProvider {
    static var dev: DeveloperPreview {
        return DeveloperPreview.shared
    }
}

class DeveloperPreview {
    static let shared = DeveloperPreview()
    
    let mockUser = User(
        fullname: "Marcos Koch",
        email: "marcos@gmail.com",
        uid: NSUUID().uuidString,
        coordinate: GeoPoint(latitude: -29.673404, longitude: -51.158742),
        accountType: .passeger
    )
}
