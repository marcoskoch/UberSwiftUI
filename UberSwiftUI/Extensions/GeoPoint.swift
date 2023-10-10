//
//  GeoPoint.swift
//  UberSwiftUI
//
//  Created by Marcos Michel on 10/10/23.
//

import Firebase
import CoreLocation

extension GeoPoint {
    func toCoordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}
