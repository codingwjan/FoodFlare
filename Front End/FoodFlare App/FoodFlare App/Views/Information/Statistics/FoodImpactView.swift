//
//  FoodImpactView.swift
//  FoodFlare
//
//  Created by Jan Pink on 18.06.23.
//

import SwiftUI
import Charts

struct FoodImpactView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Statistics.date, ascending: false)],
        animation: .default)
    private var statisticItems: FetchedResults<Statistics>

    private var highestImpactFood: (key: String, value: Double)? {
        // Create a dictionary where the keys are food items and the values are total calories per food item
        var foodCalorieDict: [String: Double] = [:]
        for item in statisticItems {
            let food = item.foodName ?? "--"
            let calories = Double(item.foodCalories)
            foodCalorieDict[food, default: 0] += calories
        }
        // Create an array of tuples (food, total calories) and sort it by total calories
        return foodCalorieDict.sorted { $1.value < $0.value }.first
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Food Impact")
                .font(.title3)
                .fontWeight(.bold)
            VStack(alignment: .leading) {
                Text("Food with the highest impact")
                if let food = highestImpactFood {
                    Text(food.key)
                        .font(.title)
                        .fontWeight(.bold)
                } else {
                    Text("No data available")
                        .font(.title)
                        .fontWeight(.bold)
                }
                createChartHorizontal(items: statisticItems, keyPath: \.foodName, xLabel: "Calories", yLabel: "Name")
            }
            .padding()
            .background(.quaternary)
            .cornerRadius(20)
        }
        .frame(height: 600)
        .padding(.top)
    }

    private func createChartHorizontal<T>(items: FetchedResults<Statistics>, keyPath: KeyPath<Statistics, T>, xLabel: String, yLabel: String) -> some View {
        // Create a dictionary where the keys are food items and the values are total calories per food item
        var foodCalorieDict: [String: Double] = [:]
        for item in statisticItems {
            let food = item.foodName ?? "--"
            let calories = Double(item.foodCalories)
            foodCalorieDict[food, default: 0] += calories
        }
        
        // Create an array of tuples (food, total calories) and sort it by total calories
        let sortedItems = foodCalorieDict.sorted { $1.value < $0.value }
        
        // Limit the list to the top 10 highest calorie foods
        let top10Items = sortedItems.prefix(10)
        
        return Chart {
            ForEach(top10Items, id: \.key) { food, totalCalories in
                BarMark(
                    x: .value("Calories", totalCalories),
                    y: .value("Food", food)
                )
                .foregroundStyle(by: .value("Shape Color", statisticItems.first(where: { $0.foodName == food })?.foodCategory ?? ""))
            }
        }
    }
    }

struct FoodImpactView_Previews: PreviewProvider {
    static var previews: some View {
        FoodImpactView()
    }
}
