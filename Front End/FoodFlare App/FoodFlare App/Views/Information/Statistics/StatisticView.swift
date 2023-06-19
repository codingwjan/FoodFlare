import SwiftUI
import CoreData
import Charts
import HealthKit

struct StatisticView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Statistics.date, ascending: false)],
        animation: .default)
    private var statisticItems: FetchedResults<Statistics>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WaterStatistics.date, ascending: false)],
        animation: .default)
    private var waterStatisticItems: FetchedResults<WaterStatistics>
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE" // day of the week
        return formatter
    }()
    
    // Create a HealthKit store
    let healthStore = HKHealthStore()
    
    @State private var todayBurned: String = ""
    
    
    func requestAuthorization() {
        let typesToShare: Set = [HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!, HKObjectType.quantityType(forIdentifier: .dietaryWater)!, HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed)!]
        let typesToRead: Set = [HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            if success {
                self.loadCalories()
            }
        }
    }
    
    func loadCalories() {
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
                                      quantitySamplePredicate: predicate,
                                      options: .cumulativeSum)
        { _, result, error in
            if let result = result,
               let sum = result.sumQuantity() {
                let unit = HKUnit.kilocalorie()
                let value = sum.doubleValue(for: unit)
                print("burned calories \(value)")
                DispatchQueue.main.async {
                    self.todayBurned = String(format: "%.0f", value)
                }
            } else {
                print("Failed to fetch calories = \(error?.localizedDescription ?? "N/A")")
            }
        }
        
        healthStore.execute(query)
    }
    
    
    
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
    
    var todayWater: Double {
        let startOfToday = Calendar.current.startOfDay(for: Date())
        return Double(waterStatisticItems.filter { $0.date ?? Date() >= startOfToday }.reduce(0) { $0 + $1.waterAmount })
    }
    
    var totalWater: Double {
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return Double(waterStatisticItems.filter { $0.date ?? Date() >= oneWeekAgo }.reduce(0) { $0 + $1.waterAmount })
    }
    
    
    var body: some View {
        VStack {
            TodayView(todayCalories: todayCalories, todayBurned: todayBurned, todayWater: todayWater, todaySugar: todaySugar)
            WeeklyCaloriesView(totalCalories: totalCalories)
            WeeklyWaterView(totalWater: totalWater)
            FoodImpactView()
            WeeklySugarView(totalSugar: totalSugar)
        }
        .padding()
        .onAppear {
            requestAuthorization()
        }
    }
}

struct StatisticView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticView()
    }
}
