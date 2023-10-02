//
//  AuthViewModel.swift
//  UberSwiftUI
//
//  Created by Marcos Michel on 25/09/23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    init() {
        userSession = Auth.auth().currentUser
        fetchUser()
    }
    
    func signIn(withEmail email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("DEBUG: Failed to sign in with error: \(error.localizedDescription)")
                return
            }
            
            self.userSession = result?.user
        }
    }
    
    func registerUser(withEmail email: String, password: String, fullname: String) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("DEBUG: Failed to sign up with error: \(error.localizedDescription)")
                return
            }
            
            guard let firebaseUser = result?.user else { return }
            self.userSession = firebaseUser
            
            let user = User(
                fullname: fullname,
                email: email,
                uid: firebaseUser.uid,
                coordinate: GeoPoint(latitude: -29.673404, longitude: -51.158742),
                accountType: .passeger
            )
            
            guard let encondedUser = try? Firestore.Encoder().encode(user) else { return }
            
            Firestore.firestore().collection("users").document(firebaseUser.uid).setData(encondedUser)
        }
    }
    
    func signout() {
        do {
            try Auth.auth().signOut()
            userSession = nil
        } catch let error {
            print("DEBUG: Failed to sign out with error: \(error.localizedDescription)")
        }
    }
    
    func fetchUser() {
        guard let uid = userSession?.uid else { return }
        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, _ in
            guard let snapshot = snapshot else { return }
            guard let user = try? snapshot.data(as: User.self) else { return }
            
            self.currentUser = user
        }
    }
}
