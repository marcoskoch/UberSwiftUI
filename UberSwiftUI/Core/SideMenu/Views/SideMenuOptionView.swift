//
//  SideMenuOptionView.swift
//  UberSwiftUI
//
//  Created by Marcos Michel on 26/09/23.
//

import SwiftUI

struct SideMenuOptionView: View {
    let sideMenuViewModel: SideMenuViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: sideMenuViewModel.imageName)
                .font(.title2)
                .imageScale(.medium)
            
            Text(sideMenuViewModel.title)
                .font(.system(size: 16, weight: .semibold))
            
            Spacer()
        }
        .foregroundColor(Color.theme.primaryTextColor)
    }
}

struct SideMenuOptionView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuOptionView(sideMenuViewModel: .trips)
    }
}
