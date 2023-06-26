//
//  SheetContentView.swift
//  FoodFlare
//
//  Created by Jan Pink on 23.06.23.
//

import SwiftUI

struct SheetContentView: View {
    @State private var searchText = ""  // Search text state
    var body: some View {
                Home()
    }
}

struct SheetContentView_Previews: PreviewProvider {
    static var previews: some View {
        SheetContentView()
    }
}
