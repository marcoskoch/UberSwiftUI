//
//  UberSwiftUIApp.swift
//  UberSwiftUI
//
//  Created by Marcos Michel on 28/07/23.
//

import SwiftUI

@main
struct UberSwiftUIApp: App {
    
    @StateObject var locationSearchViewModel = LocationSearchViewModel()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(locationSearchViewModel)
        }
    }
}
