//
//  ItemBoxView.swift
//  FoodFlare
//
//  Created by Jan Pink on 14.06.23.
//

import SwiftUI

struct ItemBoxView: View {
    var icon: String
    var text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(text)
        }
        .padding(10.0)
        .background(.tertiary)
        .cornerRadius(8.0)
    }
}


struct ItemBoxView_Previews: PreviewProvider {
    @State static var shouldShow = true
    
    static var previews: some View {
        ItemBoxView(icon: "circle", text: "--")
    }
}
