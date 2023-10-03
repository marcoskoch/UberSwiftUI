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

class HomeViewModel: ObservableObject {
    
    @Published var drivers = [User]()
    private let userService = UserService.shared
    var currentUser: User?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchUser()
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
    
    func fetchUser() {
        userService.$user
            .sink { user in
                guard let user = user else { return }
                self.currentUser = user
                guard user.accountType == .passeger else { return }
                self.fetchDrivers()
            }
            .store(in: &cancellables)
    }
}
