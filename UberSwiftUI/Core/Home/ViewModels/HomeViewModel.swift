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
    @Published var trip: Trip? 
    private let userService = UserService.shared
    var currentUser: User?
    private var cancellables = Set<AnyCancellable>()
    var routePickupLocation: MKRoute?
    
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
    
    // MARK: - Helpers
    
    var tripCancelledMessage: String {
        guard let user = currentUser, let trip = trip else { return "" }
        var message = ""
        
        if user.accountType == .passeger {
            if trip.state == .driverCancelled {
                message = "Your driver cancelled this trip"
            } else {
                message = "Your trip has been cancelled"
            }
        } else {
            if trip.state == .driverCancelled {
                message = "Your trip has been cancelled"
            } else {
                message = "The trip has been cancelled by passanger"
            }
        }
        
        return message
    }
    
    func viewForState(_ state: MapViewState, user: User) -> some View {
        switch state {
        case .polylineAdded:
            return AnyView(RideRequestView())
        case .tripRequested:
            if user.accountType == .passeger {
                return AnyView(TripLoadingView())
            } else {
                if let trip = self.trip {
                    return AnyView(AcceptTripView(trip: trip))
                }
            }
        case .tripAccepted:
            if user.accountType == .passeger {
                return AnyView(TripAcceptedView())
            } else {
                if let trip = self.trip {
                    return AnyView(PickupPassengerView(trip: trip))
                }
            }
        case .tripCancelledByPassenger, .tripCancelledByDriver:
            return AnyView(TripCancelledView())
        default:
            break
        }
        
        return AnyView(Text(""))
    }
    
    // MARK: - User API
    
    func fetchUser() {
        userService.$user
            .sink { user in
                guard let user = user else { return }
                self.currentUser = user
                if user.accountType == .passeger {
                    self.fetchDrivers()
                    self.addTripObserverForPassenger()
                } else {
//                    self.fetchTrips()
                    self.addTripObserverForDriver()
                }
            }
            .store(in: &cancellables)
    }
    
    func updateTripState(state: TripState) {
        guard let trip = trip else { return }
        
        var data = ["state": state.rawValue]
        
        if state == .accepted {
            data["travelTimeToPassenger"] = trip.travelTimeToPassenger
        }
        
        Firestore.firestore().collection("trips").document(trip.id).updateData(data) { _ in
            print("DEBUG: Did update trip with state: \(state)")
        }
    }
    
    func deleteTrip() {
        guard let trip = trip else { return }
        
        Firestore.firestore().collection("trips").document(trip.id).delete() { _ in
            self.trip = nil
        }
    }
}

// MARK: - Passanger API

extension HomeViewModel {
    
    func addTripObserverForPassenger() {
        guard let currentUser = currentUser, currentUser.accountType == .passeger else { return }
        
        Firestore.firestore().collection("trips")
            .whereField("passengerUid", isEqualTo: currentUser.uid)
            .addSnapshotListener { snapshot, _ in
                guard let change = snapshot?.documentChanges.first,
                      change.type == .added || change.type == .modified else { return }
                
                guard let trip = try? change.document.data(as: Trip.self) else { return }
                
                self.trip = trip
            }
    }
    
    func fetchDrivers() {
        Firestore.firestore().collection("users")
            .whereField("accountType", isEqualTo: AccountType.driver.rawValue)
            .getDocuments { snapshot, _ in
                guard let documents = snapshot?.documents else { return }
                let drivers =  documents.compactMap({ try? $0.data(as: User.self)})
                self.drivers = drivers
            }
    }
    
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
            let tripCost = self.computeRidePrice(forType: .uberX)
            
            let trip = Trip(
                passengerUid: currentUser.uid,
                driverUid: driver.uid,
                passengerName: currentUser.fullname,
                driverName: driver.fullname,
                passengerLocation: currentUser.coordinate,
                driverLocation: driver.coordinate,
                pickupLocationName: placemark.name ?? "Current Location",
                dropoffLocationName: dropOffLocation.title,
                pickupLocationAddress: self.addressFromPlacemark(placemark),
                pickupLocation: currentUser.coordinate,
                dropoffLocation: dropoffGeoPoint,
                tripCost: tripCost,
                distanceToPassenger: 0,
                travelTimeToPassenger: 0,
                state: .requested
            )
            
            guard let encodedTrip = try? Firestore.Encoder().encode(trip) else { return }
            Firestore.firestore().collection("trips").document().setData(encodedTrip) { _ in
                print("DEBUG: Did upload trip to firestore")
            }
        }
    }
    
    func cancelTripAsPassenger() {
        updateTripState(state: .passengerCancelled)
    }
}

// MARK: - Driver API

extension HomeViewModel {
    func addTripObserverForDriver() {
        guard let currentUser = currentUser, currentUser.accountType == .driver else { return }
        
        Firestore.firestore().collection("trips")
            .whereField("driverUid", isEqualTo: currentUser.uid)
            .addSnapshotListener { snapshot, _ in
                guard let change = snapshot?.documentChanges.first,
                      change.type == .added || change.type == .modified else { return }
                
                guard let trip = try? change.document.data(as: Trip.self) else { return }
                
                self.trip = trip
                
                self.getDestinationRoute(from: trip.driverLocation.toCoordinate(), to: trip.pickupLocation.toCoordinate()) { route in
                    self.routePickupLocation = route
                    self.trip?.travelTimeToPassenger = Int(route.expectedTravelTime / 60)
                    self.trip?.distanceToPassenger = route.distance
                }
            }
    }
    
//    func fetchTrips() {
//        guard let currentUser = currentUser else { return }
//
//        Firestore.firestore().collection("trips")
//            .whereField("driverUid", isEqualTo: currentUser.uid)
//            .getDocuments { snapshot, _ in
//                guard let documents = snapshot?.documents, let document = documents.first else { return }
//                guard let trip = try? document.data(as: Trip.self) else { return }
//
//                print("DEBUG: trip: \(trip)")
//
//                self.trip = trip
//
//                self.getDestinationRoute(from: trip.driverLocation.toCoordinate(), to: trip.pickupLocation.toCoordinate()) { route in
//                    self.trip?.travelTimeToPassenger = Int(route.expectedTravelTime / 60)
//                    self.trip?.distanceToPassenger = route.distance
//                }
//            }
//    }
    
    func rejectTrip() {
        updateTripState(state: .rejected)
    }
    
    func acceptTrip() {
        updateTripState(state: .accepted)
    }
    
    func cancelTripAsDriver() {
        updateTripState(state: .driverCancelled)
    }
}

// MARK: - Location Search Helpers

extension HomeViewModel {
    
    func addressFromPlacemark(_ placemark: CLPlacemark) -> String {
        var result = ""
        
        if let thoroughfare = placemark.thoroughfare {
            result += thoroughfare
        }
        
        if let subThoroughfare = placemark.subThoroughfare {
            result += " \(subThoroughfare)"
        }
        
        if let subAdministrativeArea = placemark.subAdministrativeArea {
            result += ", \(subAdministrativeArea)"
        }
        
        return result
    }
    
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
    
    func computeRidePrice(forType type: RideType) -> Double {
        guard let coordinate = selectedUberLocation?.coordinate else { return 0.0 }
        guard let userCoordinate = self.userLocation else { return 0.0 }
        
        let userLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
        let destination = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        let tripDistanceInMeters = destination.distance(from: userLocation)
        
        return type.computePrice(for: tripDistanceInMeters)
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
