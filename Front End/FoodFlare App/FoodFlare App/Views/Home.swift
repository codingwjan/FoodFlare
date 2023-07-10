import SwiftUI
import Combine
import CoreData
import HealthKit

class TitleAnimator: ObservableObject {
    @Published var title: String = ""
    private var counter = 0
    let fullTitle = "FoodFlare"
    let timer = Timer.publish(every: 0.07, on: .main, in: .common).autoconnect()
    private var cancellables = Set<AnyCancellable>()
    let feedbackGeneratorSoft = UIImpactFeedbackGenerator(style: .soft)
    
    init() {
        timer
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.counter < self.fullTitle.count {
                    self.counter += 1
                    self.title = String(self.fullTitle.prefix(self.counter))
                    self.feedbackGeneratorSoft.impactOccurred()
                }
            }
            .store(in: &cancellables)
    }
}

struct Home: View {
    let feedbackGeneratorMedium = UIImpactFeedbackGenerator(style: .medium)
    @StateObject private var titleAnimator = TitleAnimator()
    
    @State private var showingActionSheet = false
    @State private var pickerSelection: Int? = 1
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    @State private var waterAmount: Double = 0.5
    
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
            } else if let error = error {
                print("Failed to fetch calories = \(error.localizedDescription)")
            } else {
                print("Burned calories are 0 or not available.")
                DispatchQueue.main.async {
                    self.todayBurned = "0"
                }
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
        NavigationView {
            ScrollView {
                VStack {
                    TodayView(todayCalories: todayCalories, todayBurned: todayBurned, todaySugar: todaySugar, todaySugarGoal: 5, overviewShowMore: true)
                    HistoryView()
                    NavigationLink {
                        DeveloperView()
                    } label: {
                        HStack {
                            Image(systemName: "hammer.circle")
                            VStack(alignment: .leading) {
                                Text("Developer Menu")
                                    .foregroundColor(Color.primary)
                                    .font(.title)
                                    .fontWeight(.medium)
                                Text("Change settings for testing")
                                    .fontWeight(.light)
                                    .foregroundColor(Color.secondary)
                            }
                            Spacer()
                        }
                    }
                }
                .padding()
            }
            .onAppear {
                requestAuthorization()
            }
            .navigationTitle(titleAnimator.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                NavigationLink {
                    ManualItemAddView()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
