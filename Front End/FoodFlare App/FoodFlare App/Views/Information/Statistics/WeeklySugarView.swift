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
        // Create a sorted version of statisticItems
        let sortedItems = statisticItems.sorted { $0.foodCategory ?? "" < $1.foodCategory ?? "" }
        let dateFormatter: DateFormatter = {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE" // day of the week
                return formatter
            }()
        
        return Chart {
            ForEach(sortedItems, id: \.self) { statistic in
                BarMark(
                    x: .value("Day", dateFormatter.string(from: statistic.date ?? Date())),
                    y: .value("Calories", Double(statistic.foodCalories))
                )
                .foregroundStyle(by: .value("Shape Color", statistic.foodCategory ?? ""))
            }
        }
        .frame(height: 200)
    }
}

struct WeeklySugarView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklySugarView(totalSugar: 15)
    }
}
