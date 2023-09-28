//
//  SettingsView.swift
//  UberSwiftUI
//
//  Created by Marcos Michel on 26/09/23.
//

import SwiftUI

struct SettingsView: View {
    
    private let user: User
    @EnvironmentObject var authViewModel: AuthViewModel
    
    init(user: User) {
        self.user = user
    }
    
    var body: some View {
        VStack {
            List {
                Section {
                    // user info header
                    
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
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .imageScale(.small)
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 8)
                }
                
                Section("Favorites") {
                    
                    ForEach(SavedLocationViewModel.allCases) { viewModel in
                        NavigationLink {
                            Text(viewModel.title)
                        } label: {
                            SavedLocationRowView(viewModel: viewModel)
                        }
                    }

                }
                
                Section("Settings") {
                    
                    SettingsRowView(imageName: "bell.circle.fill", title: "Notification", tintColor: Color(.systemPurple))
                    
                    SettingsRowView(imageName: "creditcard.circle.fill", title: "Payment Methods", tintColor: Color(.systemBlue))
                    
                }
                
                Section("Account") {
                    SettingsRowView(imageName: "dollarsign.circle.fill", title: "Make Money Driving", tintColor: Color(.systemGreen))
                    
                    SettingsRowView(imageName: "arrow.left.circle.fill", title: "Sign Out", tintColor: Color(.systemRed))
                        .onTapGesture {
                            authViewModel.signout()
                        }
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView(user: User(fullname: "Marcos Koch",
                                    email: "marcos@gmail.com",
                                    uid: "9o87quwy879fads87"))
        }
    }
}
