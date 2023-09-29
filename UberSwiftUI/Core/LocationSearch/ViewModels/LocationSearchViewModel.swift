//
//  LocationSearchViewModel.swift
//  UberSwiftUI
//
//  Created by Marcos Michel on 17/08/23.
//

import Foundation
import MapKit
import Firebase

enum LocationResultsViewConfig {
    case ride
    case saveLocation(SavedLocationViewModel)
}

class LocationSearchViewModel: NSObject, ObservableObject {
    
    // MARK: - Properties
    
    @Published var results = [MKLocalSearchCompletion]()
    @Published var selectedUberLocation: UberLocation?
    @Published var pickupTime: String?
    @Published var dropOfTime: String?
    
    private let searchCompleter = MKLocalSearchCompleter()
    var queryFragment: String = "" {
        didSet {
            searchCompleter.queryFragment = queryFragment
        }
    }
    
    var userLocation: CLLocationCoordinate2D?
    
    // MARK: - Lifecycle
    
    override init() {
        super.init()
        searchCompleter.delegate = self
        searchCompleter.queryFragment = queryFragment
    }
    
    // MARK: - Helpers
    
    func selectLocation(_ localSearch: MKLocalSearchCompletion, config: LocationResultsViewConfig) {
        
        locationSearch(forLocalSearchCompletion: localSearch) { response, error in
            if let error = error {
                print("DEBUG: Location search failed with error \(error)")
                return
            }
            
            guard let item = response?.mapItems.first else { return }
            let coordinate = item.placemark.coordinate
            
            switch config {
            case .ride:
                self.selectedUberLocation = UberLocation(title: localSearch.title, coordinate: coordinate)
            case .saveLocation(let viewModel):
                guard let uid = Auth.auth().currentUser?.uid else { return }
                let savedLocation = SavedLocation(title: localSearch.title,
                                                  address: localSearch.subtitle,
                                                  coordinates: GeoPoint(latitude: coordinate.latitude,
                                                                        longitude: coordinate.longitude))
                
                guard let encodedLocation = try? Firestore.Encoder().encode(savedLocation) else { return }
                Firestore.firestore().collection("users").document(uid).updateData([
                    viewModel.databaseKey: encodedLocation
                ])
            }
            
            
        }
        
    }
    
    func locationSearch(forLocalSearchCompletion localSearch: MKLocalSearchCompletion, completion: @escaping MKLocalSearch.CompletionHandler) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = localSearch.title.appending(localSearch.subtitle)
        let search = MKLocalSearch(request: searchRequest)
        
        search.start(completionHandler: completion)
    }
    
    func computeRidePrice(forType type: RideType) -> String {
        guard let coordinate = selectedUberLocation?.coordinate else { return "" }
        guard let userCoordinate = self.userLocation else { return "" }
        
        let userLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
        let destination = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        let tripDistanceInMeters = destination.distance(from: userLocation)
        
        return type.computePrice(for: tripDistanceInMeters).toCurrency()
    }
    
    func getDestinationRoute(from userLocation: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, completion: @escaping(MKRoute) -> Void) {
        let userPlacemark = MKPlacemark(coordinate: userLocation)
        let destPlacemark = MKPlacemark(coordinate: destination)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: userPlacemark)
        request.destination = MKMapItem(placemark: destPlacemark)
        let directions = MKDirections(request: request)
        
        directions.calculate { response, error in
            if let error = error {
                print("DEBUG: Failed to get directions with error \(error.localizedDescription)")
                return
            }
            
            guard let route = response?.routes.first else { return }
            self.configurePickupAndDropOfTimes(with: route.expectedTravelTime)
            completion(route)
        }
    }
    
    func configurePickupAndDropOfTimes(with expectedTravelTime: Double) {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        
        let now = Date() + 60 * 2
        
        pickupTime = formatter.string(from: now)
        dropOfTime = formatter.string(from: now + expectedTravelTime)
    }
    
}

// MARK: - MKLocalSearchCompleterDelegate

extension LocationSearchViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.results = completer.results
    }
}
