//
//  WeeklySugarView.swift
//  FoodFlare
//
//  Created by Jan Pink on 18.06.23.
//

import SwiftUI
import Charts

struct WeeklyWaterView: View {
    let totalWater: Double
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WaterStatistics.date, ascending: false)],
        animation: .default)
    private var waterStatisticItems: FetchedResults<WaterStatistics>
    var body: some View {
        VStack(alignment: .leading) {
            Text("Weekly Water")
                .font(.title3)
                .fontWeight(.bold)
            VStack(alignment: .leading) {
                Text("Total Water in the past 7 Days")
                Text("\(String(format: "%.2f", totalWater)) liters")
                    .font(.title)
                    .fontWeight(.bold)
                createChartVertical(items: waterStatisticItems, keyPath: \.waterAmount, xLabel: "Day", yLabel: "Water")
            }
            .padding()
            .background(.quaternary)
            .cornerRadius(20)
        }
        .padding(.top)

    }
    
    
    // New function to create chart
    private func createChartVertical<T>(items: FetchedResults<WaterStatistics>, keyPath: KeyPath<WaterStatistics, T>, xLabel: String, yLabel: String) -> some View {
        let daysOfTheWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

        return Chart {
            ForEach(0..<7, id: \.self) { dayIndex in
                // If a statistic exists for the given day of the week, get the water amount.
                // Otherwise, use a water amount of 0.
                let statisticForDay = items.first(where: {
                    let weekday = Calendar.current.component(.weekday, from: $0.date ?? Date())
                    // Adjust index because Calendar component .weekday starts with 1 for Sunday.
                    return (weekday % 7) == dayIndex
                })
                let waterAmount = Double(statisticForDay?.waterAmount ?? 0)

                BarMark(
                    x: .value("Day", daysOfTheWeek[dayIndex]),
                    y: .value("Water", waterAmount)
                )
                .foregroundStyle(Color.cyan)
            }
        }
        .frame(height: 300)
    }

}

struct WeeklyWaterView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyWaterView(totalWater: 4.5)
    }
}
