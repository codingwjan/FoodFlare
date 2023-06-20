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
        TabView {
            NavigationView {
                Home()
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            
            NavigationView {
                ManualItemAddView()
            }
            .tabItem {
                Label("Food" , systemImage: "carrot.fill")
            }

            NavigationView {
                CameraView()
            }
            .tabItem {
                Label("Scan", systemImage: "camera")
            }
            
            NavigationView {
                AddWaterView(waterAmount: $waterAmount)
            }
            .tabItem {
                Label("Water", systemImage: "drop.fill")
            }

            NavigationView {
                InformationView()
            }
            .tabItem {
                Label("Information", systemImage: "person")
            }
            
            NavigationView {
                DeveloperView()
            }
            .tabItem {
                Label("Developer", systemImage: "hammer")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
