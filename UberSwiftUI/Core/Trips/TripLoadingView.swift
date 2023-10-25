//
//  TripLoadingView.swift
//  UberSwiftUI
//
//  Created by Marcos Michel on 24/10/23.
//

import SwiftUI

struct TripLoadingView: View {
    var body: some View {
        VStack {
            Text("Finding you a ride...")
                .padding()
        }
        .padding(.bottom, 24)
        .background(Color.theme.backgroundColor)
        .cornerRadius(16)
    }
}

struct TripLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        TripLoadingView()
    }
}
