//
//  InformationView.swift
//  FoodFlare
//
//  Created by Jan Pink on 19.06.23.
//

import SwiftUI

struct InformationView: View {
    var body: some View {
        ScrollView {
            StatisticView()
            HistoryView()
        }
        .navigationTitle("Information")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct InformationView_Previews: PreviewProvider {
    static var previews: some View {
        InformationView()
    }
}
