//
//  SavedLocationSearchView.swift
//  UberSwiftUI
//
//  Created by Marcos Michel on 28/09/23.
//

import SwiftUI

struct SavedLocationSearchView: View {
    
//    @State private var text = ""
    @StateObject var viewModel = LocationSearchViewModel()
    let config: SavedLocationViewModel
    
    var body: some View {
        VStack {
            TextField("Search for a location..", text: $viewModel.queryFragment)
                .frame(height: 32)
                .padding(.leading)
                .background(Color(.systemGray5))
                .padding()
            
            Spacer()
            
            LocationSearchResultsView(viewModel: viewModel, config: .saveLocation(config))
        }
        .navigationTitle(config.subtitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SavedLocationSearchView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SavedLocationSearchView(config: .home)
        }
    }
}
