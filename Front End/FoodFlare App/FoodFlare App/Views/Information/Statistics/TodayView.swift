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
    let todayBurned: String
    let todayWater: Double
    let todaySugar: Int
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(Date(), formatter: DateFormatter.day)")
                .font(.title)
                .fontWeight(.bold)
                
            HStack {
                Text("Calories")
                    .frame(width: 70, alignment: .leading)
                Spacer()
                HStack(alignment: .center, spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("Eaten")
                            .foregroundColor(.secondary)
                            .frame(width: 80, alignment: .leading)
                        Text("\(todayCalories)")
                            .font(.title)
                            .fontWeight(.semibold)
                    }
                    VStack(alignment: .leading) {
                        Text("Burned")
                            .foregroundColor(.secondary)
                            .frame(width: 80, alignment: .leading)
                        Text("\(todayBurned)")
                            .font(.title)
                            .fontWeight(.semibold)
                    }
                }
            }
            .padding(.top)

            HStack {
                Text("Water")
                    .frame(width: 70, alignment: .leading)
                Spacer()
                HStack(alignment: .center, spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("Drunken")
                            .foregroundColor(.secondary)
                            .frame(width: 80, alignment: .leading)
                        Text("\(String(format: "%.2f", todayWater))")
                            .font(.title)
                            .fontWeight(.semibold)
                    }
                    VStack(alignment: .leading) {
                        Text("Goal")
                            .foregroundColor(.secondary)
                            .frame(width: 80, alignment: .leading)
                        Text("4.00")
                            .font(.title)
                            .fontWeight(.semibold)
                    }
                }
            }
            .padding(.top)
        }
        .padding()
        .overlay(RoundedRectangle(cornerRadius: 17.0).stroke(.tertiary, lineWidth: 1))

    }
}

extension DateFormatter {
    static var day: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE" // EEEE format for full day name
        return formatter
    }
}


struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        TodayView(todayCalories: 15, todayBurned: "12", todayWater: 0.75, todaySugar: 15)
    }
}
