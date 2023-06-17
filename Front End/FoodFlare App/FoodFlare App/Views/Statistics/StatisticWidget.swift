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
        let totalCalories: Int16

        // Computed property to get day name
        var dayName: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE" // day of week style
            return formatter.string(from: id)
        }
    }

    // Incoming data from the StatisticView
    let lastSevenDaysData: [Day]

    var body: some View {
        Chart {
            ForEach(lastSevenDaysData, id: \.id) { day in
                BarMark(
                    x: .value("Day", day.dayName),
                    y: .value("Calories",day.totalCalories)
                )
                .foregroundStyle(.blue)  // You can change the color according to your preference
            }
        }
        .onAppear {
            print("Rendering StatisticWidget View")
            print("Last seven days data: \(lastSevenDaysData)")
        }
    }
}

struct StatisticWidget_Previews: PreviewProvider {
    static var previews: some View {
        let demoData = [
            StatisticWidget.Day(id: Date().addingTimeInterval(-6*24*60*60), totalCalories: 2000),
            StatisticWidget.Day(id: Date().addingTimeInterval(-5*24*60*60), totalCalories: 1500),
            StatisticWidget.Day(id: Date().addingTimeInterval(-4*24*60*60), totalCalories: 1800),
            StatisticWidget.Day(id: Date().addingTimeInterval(-3*24*60*60), totalCalories: 2200),
            StatisticWidget.Day(id: Date().addingTimeInterval(-2*24*60*60), totalCalories: 1600),
            StatisticWidget.Day(id: Date().addingTimeInterval(-1*24*60*60), totalCalories: 1700),
            StatisticWidget.Day(id: Date(), totalCalories: 2000),
        ]
        
        return StatisticWidget(lastSevenDaysData: demoData)
    }
}
