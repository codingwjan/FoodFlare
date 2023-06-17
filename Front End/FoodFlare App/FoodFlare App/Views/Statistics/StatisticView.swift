import SwiftUI
import CoreData
import Charts

struct StatisticView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Statistics.date, ascending: false)],
        animation: .default)
    private var statisticItems: FetchedResults<Statistics>
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE" // day of the week
        return formatter
    }()

    // Added a computed property to calculate total calories for last 7 days
    var totalCalories: Int {
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return statisticItems.filter { $0.date ?? Date() >= oneWeekAgo }.reduce(0) { $0 + Int($1.foodCalories) }
    }
    
    var todayCalories: Int {
        let startOfToday = Calendar.current.startOfDay(for: Date())
        return statisticItems.filter { $0.date ?? Date() >= startOfToday }.reduce(0) { $0 + Int($1.foodCalories) }
    }
    
    var totalSugar: Int {
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return Int(statisticItems.filter { $0.date ?? Date() >= oneWeekAgo }.reduce(0) { $0 + $1.foodSugar })
    }

    var todaySugar: Int {
        let startOfToday = Calendar.current.startOfDay(for: Date())
        return Int(statisticItems.filter { $0.date ?? Date() >= startOfToday }.reduce(0) { $0 + $1.foodSugar })
    }

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Today")
                    .font(.title3)
                    .fontWeight(.bold)
                HStack {
                    VStack(alignment: .leading) {
                        Text("Calories")
                        Text("\(todayCalories) cal")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Sugar")
                        Text("\(todaySugar) g")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    Spacer()
                }
                .padding()
                .background(.quaternary)
                .cornerRadius(20)
            }
            VStack(alignment: .leading) {
                Text("Weekly Calories")
                    .font(.title3)
                    .fontWeight(.bold)
                VStack(alignment: .leading) {
                    Text("Total Energy in Past 7 Days")
                    Text("\(totalCalories) Calories")
                        .font(.title)
                        .fontWeight(.bold)
                    createChartVertical(items: statisticItems, keyPath: \.foodCalories, xLabel: "Day", yLabel: "Calories")
                }
                .padding()
                .background(.quaternary)
                .cornerRadius(20)
            }
            .padding(.top)
            VStack(alignment: .leading) {
                Text("Weekly Sugar")
                    .font(.title3)
                    .fontWeight(.bold)
                VStack(alignment: .leading) {
                    Text("Total Sugar in Past 7 Days")
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
            VStack(alignment: .leading) {
                Text("Food Impact")
                    .font(.title3)
                    .fontWeight(.bold)
                VStack(alignment: .leading) {
                    Text("Food with the highest impact")
                    Text("Banana")
                        .font(.title)
                        .fontWeight(.bold)
                    createChartHorizontal(items: statisticItems, keyPath: \.foodName, xLabel: "Calories", yLabel: "Name")
                    
                }
                .padding()
                .background(.quaternary)
                .cornerRadius(20)
            }
            .padding(.top)
        }
        .padding()
    }

    
    // New function to create chart
    private func createChartVertical<T>(items: FetchedResults<Statistics>, keyPath: KeyPath<Statistics, T>, xLabel: String, yLabel: String) -> some View {
        // Create a sorted version of statisticItems
        let sortedItems = statisticItems.sorted { $0.foodCategory ?? "" < $1.foodCategory ?? "" }
        
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
        
        return Chart {
            ForEach(sortedItems, id: \.key) { food, totalCalories in
                BarMark(
                    x: .value("Calories", totalCalories),
                    y: .value("Food", food)
                )
                .foregroundStyle(by: .value("Shape Color", statisticItems.first(where: { $0.foodName == food })?.foodCategory ?? ""))
            }
        }
        .frame(height: 200)
    }
}

struct StatisticView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticView()
    }
}
