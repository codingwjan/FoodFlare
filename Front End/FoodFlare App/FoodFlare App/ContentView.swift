//
//  ContentView.swift
//  FoodFlare App
//
//  Created by Jan Pink on 13.06.23.
//

import SwiftUI

struct ContentView: View {
    @State private var waterAmount: Double = 0.5

    var body: some View {
            CameraView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
