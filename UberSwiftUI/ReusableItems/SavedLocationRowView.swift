//
//  SavedLocationRowView.swift
//  UberSwiftUI
//
//  Created by Marcos Michel on 26/09/23.
//

import SwiftUI

struct SavedLocationRowView: View {
    
    let viewModel: SavedLocationViewModel
    
    var body: some View {
        HStack {
            Image(systemName: viewModel.imageName)
                .imageScale(.medium)
                .font(.title)
                .foregroundColor(Color(.systemBlue))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color.theme.primaryTextColor)
                
                Text(viewModel.subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
        }
    }
}

struct SavedLocationRowView_Previews: PreviewProvider {
    static var previews: some View {
        SavedLocationRowView(viewModel: .home)
    }
}
