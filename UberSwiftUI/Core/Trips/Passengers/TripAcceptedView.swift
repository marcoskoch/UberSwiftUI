//
//  TripAcceptedView.swift
//  UberSwiftUI
//
//  Created by Marcos Michel on 24/10/23.
//

import SwiftUI

struct TripAcceptedView: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    var body: some View {
        VStack {
            Capsule()
                .fill(Color(.systemGray5))
                .frame(width: 48, height: 6)
                .padding(.top, 8)
            
            if let trip = homeViewModel.trip {
                VStack {
                    HStack {
                        Text("Meet your driver at \(trip.pickupLocationName) from you trip to \(trip.dropoffLocationName)")
                            .font(.body)
                            .frame(height: 44)
                            .lineLimit(2)
                            .padding(.trailing)
                        
                        Spacer()
                        
                        VStack {
                            Text("\(trip.travelTimeToPassenger)")
                            
                            Text("min")
                        }
                        .frame(width: 56, height: 56)
                        .foregroundColor(.white)
                        .background(Color(.systemBlue))
                        .cornerRadius(10)
                        .bold()
                    }
                    .padding()
                    
                    Divider()
                }
                
                VStack {
                    HStack {
                        Image("perfil")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(trip.driverName)
                                .fontWeight(.bold)
                            
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(Color(.systemYellow))
                                    .imageScale(.small)
                                
                                Text("4.8")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .center) {
                            Image("uber-x")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 64)
                            
                            HStack {
                                Text("Mercedes S -")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.gray)
                                
                                Text("5G43K08")
                                    .font(.system(size: 14, weight: .semibold))
                                
                            }
                            .frame(width: 165)
                            .padding(.bottom)
                        }
                        
                    }
                    
                    Divider()
                }
                .padding()
            }
            
            
            Button {
                homeViewModel.cancelTripAsPassenger()
            } label: {
                Text("CANCEL RIDE")
                    .fontWeight(.bold)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 50)
                    .background(.red)
                    .cornerRadius(10)
                    .foregroundColor(.white)
            }
            
        }
        .padding(.bottom, 24)
        .background(Color.theme.backgroundColor)
        .cornerRadius(16)
        .shadow(color: Color.theme.secondaryBackgroundColor, radius: 20)
    }
}

struct TripAcceptedView_Previews: PreviewProvider {
    static var previews: some View {
        TripAcceptedView()
    }
}
