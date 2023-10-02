//
//  HomeViewModel.swift
//  UberSwiftUI
//
//  Created by Marcos Michel on 02/10/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

class HomeViewModel: ObservableObject {
    
    init() {
        fetchDrivers()
    }
    
    func fetchDrivers() {
        Firestore.firestore().collection("users")
            .whereField("accountType", isEqualTo: AccountType.driver.rawValue)
            .getDocuments { snapshot, _ in
                guard let documents = snapshot?.documents else { return }
                let drivers =  documents.map({ try? $0.data(as: User.self)})
                
                print("DEBUG: Drivers \(drivers)")
            }
    }
}
