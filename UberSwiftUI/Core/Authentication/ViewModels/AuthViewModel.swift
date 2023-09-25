//
//  AuthViewModel.swift
//  UberSwiftUI
//
//  Created by Marcos Michel on 25/09/23.
//

import Foundation
import Firebase

class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    
    init() {
        userSession = Auth.auth().currentUser 
    }
}
