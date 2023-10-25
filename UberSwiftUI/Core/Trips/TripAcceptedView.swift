//
//  TripAcceptedView.swift
//  UberSwiftUI
//
//  Created by Marcos Michel on 24/10/23.
//

import SwiftUI

struct TripAcceptedView: View {
    var body: some View {
        VStack {
            Text("Trip accepted")
                .padding()
        }
        .padding(.bottom, 24)
        .background(Color.theme.backgroundColor)
        .cornerRadius(16)
    }
}

struct TripAcceptedView_Previews: PreviewProvider {
    static var previews: some View {
        TripAcceptedView()
    }
}
