//
//  WeeklyCaloriesView.swift
//  FoodFlare
//
//  Created by Jan Pink on 18.06.23.
//

import SwiftUI
import Charts

struct WeeklyCaloriesView: View {
    let totalCalories: Int
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Statistics.date, ascending: false)],
        animation: .default)
    private var statisticItems: FetchedResults<Statistics>
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text("Total Energy in the past 7 Days")
                Text("\(totalCalories) Calories")
                    .font(.title)
                    .fontWeight(.bold)
                createChartVertical(items: statisticItems, keyPath: \.foodCalories, xLabel: "Day", yLabel: "Calories")
            }
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 17.0).stroke(.tertiary, lineWidth: 1))
        }
        .padding(.top)
    }
    
    
    // New function to create chart
    private func createChartVertical<T>(items: FetchedResults<Statistics>, keyPath: KeyPath<Statistics, T>, xLabel: String, yLabel: String) -> some View {
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
                    y: .value("Calories", Double(statistic.foodCalories))
                )
                .foregroundStyle(by: .value("Shape Color", statistic.foodCategory ?? ""))
            }
        }
        .frame(height: 300)
    }
}

struct WeeklyCaloriesView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyCaloriesView(totalCalories: 15)
    }
}
