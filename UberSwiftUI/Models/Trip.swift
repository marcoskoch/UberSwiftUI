//
//  Trip.swift
//  UberSwiftUI
//
//  Created by Marcos Michel on 04/10/23.
//

import Firebase

struct Trip: Identifiable, Codable {
    let id: String
    let passengerUid: String
    let driverUid: String
    let passengerName: String
    let driverName: String
    let passengerLocation: GeoPoint
    let driverLocation: GeoPoint
    let pickupLocationName: String
    let dropoffLocationName: String
    let pickupLocationAddress: String
    let pickupLocation: GeoPoint
    let dropoffLocation: GeoPoint
    let tripCost: Double
}
