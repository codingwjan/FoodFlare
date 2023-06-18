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
        let dateFormatter: DateFormatter = {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE" // day of the week
                return formatter
            }()
        
        return Chart {
            ForEach(items, id: \.self) { statistic in
                BarMark(
                    x: .value("Day", dateFormatter.string(from: statistic.date ?? Date())),
                    y: .value("Water", Double(statistic.waterAmount))
                )
                .foregroundStyle(Color.cyan)
            }
        }
        .frame(height: 200)
    }
}

struct WeeklyWaterView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyWaterView(totalWater: 4.5)
    }
}
