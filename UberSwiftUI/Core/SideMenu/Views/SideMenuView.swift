//
//  SideMenuView.swift
//  UberSwiftUI
//
//  Created by Marcos Michel on 25/09/23.
//

import SwiftUI

struct SideMenuView: View {
    
    private let user: User
    
    init(user: User) {
        self.user = user
    }
    
    var body: some View {
        VStack(spacing: 40) {
            // header
            
            VStack(spacing: 32) {
                // user info
                
                HStack {
                    Image("perfil")
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .frame(width: 64, height: 64)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(user.fullname)
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text(user.email)
                            .accentColor(Color.theme.primaryTextColor)
                            .opacity(0.77)
                    }
                }
                
                // become a driver
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Do more with your account")
                        .font(.footnote)
                        .fontWeight(.semibold)
                    
                    HStack {
                        Image(systemName: "dollarsign.square")
                            .font(.title2)
                            .imageScale(.medium)
                        
                        Text("Make Money Driving")
                            .font(.system(size: 16, weight: .semibold))
                            .padding(6)
                    }
                }
                
                Rectangle()
                    .frame(width: 296, height: 0.75)
                    .opacity(0.7)
                    .foregroundColor(Color(.separator))
                    .shadow(color: .black.opacity(0.7), radius: 4)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 16)
            
            
            // option list
            
            VStack {
                ForEach(SideMenuViewModel.allCases) { option in
                    NavigationLink(value: option) {
                        SideMenuOptionView(sideMenuViewModel: option)
                            .padding()
                    }
                }
            }
            .navigationDestination(for: SideMenuViewModel.self) { viewModel in
                switch viewModel {
                case .trips:
                    Text(viewModel.title)
                case .wallet:
                    Text(viewModel.title)
                case .settings:
                    SettingsView(user: user)
                case .messages:
                    Text(viewModel.title)
                }
            }
            
            Spacer()

        }
        .padding(.top, 32)
        
    }
}

struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SideMenuView(user: User(fullname: "Marcos Koch",
                                    email: "marcos@gmail.com",
                                    uid: "9o87quwy879fads87"))
        }
    }
}
