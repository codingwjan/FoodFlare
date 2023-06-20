//
//  WeeklySugarView.swift
//  FoodFlare
//
//  Created by Jan Pink on 18.06.23.
//

import SwiftUI
import Charts

struct WeeklySugarView: View {
    let totalSugar: Int
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Statistics.date, ascending: false)],
        animation: .default)
    private var statisticItems: FetchedResults<Statistics>
    var body: some View {
        VStack(alignment: .leading) {
            Text("Weekly Sugar")
                .font(.title3)
                .fontWeight(.bold)
            VStack(alignment: .leading) {
                Text("Total Sugar in the past 7 Days")
                Text("\(totalSugar) g")
                    .font(.title)
                    .fontWeight(.bold)
                createChartVertical(items: statisticItems, keyPath: \.foodSugar, xLabel: "Day", yLabel: "Sugar")
            }
            .padding()
            .background(.quaternary)
            .cornerRadius(20)
        }
        .padding(.top)

    }
    
    
    // New function to create chart
    private func createChartVertical<T>(items: FetchedResults<Statistics>, keyPath: KeyPath<Statistics, T>, xLabel: String, yLabel: String) -> some View {
        let daysOfTheWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

        return Chart {
            ForEach(0..<7, id: \.self) { dayIndex in
                // If a statistic exists for the given day of the week, get the food calories.
                // Otherwise, use a calories amount of 0.
                let statisticForDay = items.first(where: {
                    let weekday = Calendar.current.component(.weekday, from: $0.date ?? Date())
                    // Adjust index because Calendar component .weekday starts with 1 for Sunday.
                    return (weekday % 7) == dayIndex
                })
                let foodCalories = Double(statisticForDay?.foodCalories ?? 0)

                BarMark(
                    x: .value("Day", daysOfTheWeek[dayIndex]),
                    y: .value("Calories", foodCalories)
                )
                .foregroundStyle(Color.blue)
            }
        }
        .frame(height: 300)
    }
}

struct WeeklySugarView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklySugarView(totalSugar: 15)
    }
}
