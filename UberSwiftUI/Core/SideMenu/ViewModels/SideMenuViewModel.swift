//
//  SideMenuViewModel.swift
//  UberSwiftUI
//
//  Created by Marcos Michel on 26/09/23.
//

import Foundation

enum SideMenuViewModel: Int, CaseIterable, Identifiable {
    var id: Int { return rawValue }
    
    case trips
    case wallet
    case settings
    case messages
    
    var title: String {
        switch self {
        case .trips:
            return "Your Trips"
        case .wallet:
            return "Wallet"
        case .settings:
            return "Settings"
        case .messages:
            return "Messages"
        }
    }
    
    var imageName: String {
        switch self {
        case .trips:
            return "list.bullet.rectangle"
        case .wallet:
            return "creditcard"
        case .settings:
            return "gear"
        case .messages:
            return "bubble.left"
        }
    }
}
