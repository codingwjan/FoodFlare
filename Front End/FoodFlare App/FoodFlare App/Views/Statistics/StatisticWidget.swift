//
//  StatisticWidget.swift
//  FoodFlare App
//
//  Created by Jan Pink on 13.06.23.
//

import SwiftUI
import Charts

struct StatisticWidget: View {
    // Structure to hold data for each day
    struct Day: Identifiable {
        let id: Date  // Use the date as the unique identifier
        let dayName: String
        let totalCalories: Int16
    }

    // Sample data
    @State var lastSevenDaysData: [Day] = []  // This will be calculated from Core Data

    var body: some View {
        Chart {
            ForEach(lastSevenDaysData, id: \.id) { day in
                BarMark(
                    x: .value("Day", day.dayName),
                    y: .value("Calories", Double(day.totalCalories))
                )
                .foregroundStyle(.blue)  // You can change the color according to your preference
            }
        }
    }
}

struct StatisticWidget_Previews: PreviewProvider {
    static var previews: some View {
        StatisticWidget()
    }
}
