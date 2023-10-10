//
//  UberLocation.swift
//  UberSwiftUI
//
//  Created by Marcos Michel on 20/09/23.
//

import CoreLocation

struct UberLocation: Identifiable {
    let id = NSUUID().uuidString
    let title: String
    let coordinate: CLLocationCoordinate2D
}
