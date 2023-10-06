//
//  HomeViewModel.swift
//  UberSwiftUI
//
//  Created by Marcos Michel on 02/10/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import Combine
import MapKit

class HomeViewModel: NSObject, ObservableObject {
    
    // MARK: - Properties
    
    @Published var drivers = [User]()
    private let userService = UserService.shared
    var currentUser: User?
    private var cancellables = Set<AnyCancellable>()
    
    // Location search properties
    
    @Published var results = [MKLocalSearchCompletion]()
    @Published var selectedUberLocation: UberLocation?
    @Published var pickupTime: String?
    @Published var dropOfTime: String?
    
    private let searchCompleter = MKLocalSearchCompleter()
    var userLocation: CLLocationCoordinate2D?
    
    var queryFragment: String = "" {
        didSet {
            searchCompleter.queryFragment = queryFragment
        }
    }
    
    // MARK: - Lifecycle
    
    override init() {
        super.init()
        fetchUser()
        
        searchCompleter.delegate = self
        searchCompleter.queryFragment = queryFragment
    }
    
    // MARK: - User API
    
    func fetchDrivers() {
        Firestore.firestore().collection("users")
            .whereField("accountType", isEqualTo: AccountType.driver.rawValue)
            .getDocuments { snapshot, _ in
                guard let documents = snapshot?.documents else { return }
                let drivers =  documents.compactMap({ try? $0.data(as: User.self)})
                self.drivers = drivers
            }
    }
    
    func fetchUser() {
        userService.$user
            .sink { user in
                guard let user = user else { return }
                self.currentUser = user
                if user.accountType == .passeger {
                    self.fetchDrivers()
                } else {
                    self.fetchTrips()
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Passanger API

extension HomeViewModel {
    func requestTrip() {
        guard let driver = drivers.first else { return }
        guard let currentUser = currentUser else { return }
        guard let dropOffLocation = selectedUberLocation else { return }
        let dropoffGeoPoint = GeoPoint(latitude: dropOffLocation.coordinate.latitude,
                                       longitude: dropOffLocation.coordinate.longitude)
        let userLocation = CLLocation(latitude: currentUser.coordinate.latitude,
                                      longitude: currentUser.coordinate.longitude)
        
        getPlacemark(forLocation: userLocation) { placemark, error in
            guard let placemark = placemark else { return }
            
            let trip = Trip(
                id: NSUUID().uuidString,
                passengerUid: currentUser.uid,
                driverUid: driver.uid,
                passengerName: currentUser.fullname,
                driverName: driver.fullname,
                passengerLocation: currentUser.coordinate,
                driverLocation: driver.coordinate,
                pickupLocationName: placemark.name ?? "Current Location",
                dropoffLocationName: dropOffLocation.title,
                pickupLocationAddress: "55 Taruma",
                pickupLocation: currentUser.coordinate,
                dropoffLocation: dropoffGeoPoint,
                tripCost: 50.0
            )
            
            guard let encodedTrip = try? Firestore.Encoder().encode(trip) else { return }
            Firestore.firestore().collection("trips").document().setData(encodedTrip) { _ in
                print("DEBUG: Did upload trip to firestore")
            }
        }
    }
}

// MARK: - Driver API

extension HomeViewModel {
    func fetchTrips() {
        guard let currentUser = currentUser else { return }
        
        Firestore.firestore().collection("trips")
            .whereField("driverUid", isEqualTo: currentUser.uid)
            .getDocuments { snapshot, _ in
                guard let documents = snapshot?.documents, let document = documents.first else { return }
                guard let trip = try? document.data(as: Trip.self) else { return }
                
                print("DEBUG: Trip request for driver is \(trip)")
            }
    }
}

// MARK: - Location Search Helpers

extension HomeViewModel {
    
    func getPlacemark(forLocation location: CLLocation, completion: @escaping(CLPlacemark?, Error?) -> Void) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let placemark = placemarks?.first else { return }
            completion(placemark, nil)
        }
    }
    
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

extension HomeViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.results = completer.results
    }
}
