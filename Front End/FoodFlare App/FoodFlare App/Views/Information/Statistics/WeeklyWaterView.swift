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
            VStack(alignment: .leading) {
                Text("Total Water in the past 7 Days")
                Text("\(String(format: "%.2f", totalWater)) liters")
                    .font(.title)
                    .fontWeight(.bold)
                createChartVertical(items: waterStatisticItems, keyPath: \.waterAmount, xLabel: "Day", yLabel: "Water")
            }
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 17.0).stroke(.tertiary, lineWidth: 1))
        }
        .padding(.top)

    }
    
    
    // New function to create chart
    private func createChartVertical<T>(items: FetchedResults<WaterStatistics>, keyPath: KeyPath<WaterStatistics, T>, xLabel: String, yLabel: String) -> some View {
        // Sort statisticItems by date
        let sortedItems = items.sorted { $0.date ?? Date() < $1.date ?? Date() }
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE" // day of the week
            return formatter
        }()
            
        return Chart {
            ForEach(sortedItems, id: \.self) { statistic in
                BarMark(
                    x: .value("Day", dateFormatter.string(from: statistic.date ?? Date())),
                    y: .value("Calories", Double(statistic.waterAmount))
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
