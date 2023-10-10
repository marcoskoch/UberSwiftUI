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
    
    let mockTrip = Trip(
        id: NSUUID().uuidString,
        passengerUid: NSUUID().uuidString,
        driverUid: NSUUID().uuidString,
        passengerName: "Marcos Koch",
        driverName: "Kevin Bacon",
        passengerLocation: .init(latitude: 37.123, longitude: -122.1),
        driverLocation: .init(latitude: 37.123, longitude: -122.1),
        pickupLocationName: "Apple Campus",
        dropoffLocationName: "Starbucks",
        pickupLocationAddress: "123 Main St, Palo Alto CA",
        pickupLocation: .init(latitude: 37.123, longitude: -122.1),
        dropoffLocation: .init(latitude: 37.123, longitude: -122.1),
        tripCost: 47.0
    )
    
    let mockUser = User(
        fullname: "Marcos Koch",
        email: "marcos@gmail.com",
        uid: NSUUID().uuidString,
        coordinate: GeoPoint(latitude: -29.673404, longitude: -51.158742),
        accountType: .passeger
    )
}
