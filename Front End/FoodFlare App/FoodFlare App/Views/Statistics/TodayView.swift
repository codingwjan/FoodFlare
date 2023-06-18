//
//  TodayView.swift
//  FoodFlare
//
//  Created by Jan Pink on 18.06.23.
//

import SwiftUI
import HealthKit

struct TodayView: View {
    let todayCalories: Int
    let todayBurned: Int
    let todayWater: Double
    let todaySugar: Int
    
    
    var body: some View {
        
        VStack(alignment: .leading) {
            Text("Today")
                .font(.title3)
                .fontWeight(.bold)
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Calories Eaten")
                        Text("\(todayCalories) cal")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Water Drunk")
                        Text("\(String(format: "%.2f", todayWater)) l")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    Spacer()
                    
                }
                Spacer()
                HStack {
                    if HKHealthStore.isHealthDataAvailable() {
                        VStack(alignment: .leading) {
                            Text("Calories Burned")
                            Text("\(todayBurned) cal")
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        Spacer()
                    }
                    VStack(alignment: .leading) {
                        Text("Sugar Eaten")
                        Text("\(todaySugar) g")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    Spacer()
                }
            }
            .padding()
            .background(.quaternary)
            .cornerRadius(20)
        }
        .padding(.top)
    }
}

struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        TodayView(todayCalories: 15, todayBurned: 12, todayWater: 0.75, todaySugar: 15)
    }
}
