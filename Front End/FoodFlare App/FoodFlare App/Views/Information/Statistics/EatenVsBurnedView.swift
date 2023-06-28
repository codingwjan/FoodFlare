import SwiftUI
import Charts
import HealthKit
import CoreData

struct EatenVsBurnedView: View {
    @Environment(\.managedObjectContext) private var viewContext
    private var healthKitHelper = HealthKitHelper()
    private var coreDataHelper: CoreDataHelper!
    
    @State private var burnedData: Double = 0
    @State private var eatenData: [ProfitData] = []
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text("You have gained calories this week!")
                Text("\(burnedData, specifier: "%.0f") cal")
                    .font(.title)
                    .fontWeight(.bold)
                Chart {
                    ForEach(eatenData, id: \.date) { item in
                        LineMark(
                            x: .value("Date", item.date),
                            y: .value("Profit A", item.profit),
                            series: .value("Company", "A")
                        )
                        .foregroundStyle(.blue)
                    }
                    RuleMark(
                        y: .value("Threshold", 300)
                    )
                    .foregroundStyle(.red)
                }
                .frame(height: 400)
            }
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 17.0).stroke(.tertiary, lineWidth: 1))
        }
        .padding(.top)
    }
    
    init() {
        coreDataHelper = CoreDataHelper(context: viewContext)
        fetchData()
    }
    
    private func fetchData() {
        healthKitHelper.authorizeHealthKit { success, error in
            if success {
                healthKitHelper.getEnergyBurned { energy, error in
                    DispatchQueue.main.async {
                        self.burnedData = energy
                    }
                }
            } else if let error = error {
                print("HealthKit authorization failed with error: \(error)")
            }
        }
        
        let statistics = coreDataHelper.fetchStatistics()
        self.eatenData = statistics.map { ProfitData(date: $0.date!, profit: Double($0.foodCalories)) }
    }
}

struct EatenVsBurnedView_Previews: PreviewProvider {
    static var previews: some View {
        EatenVsBurnedView()
    }
}

struct ProfitData {
    let date: Date
    let profit: Double
}

class HealthKitHelper {
    private let healthStore = HKHealthStore()
    let energyQuantityType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
    
    func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Void) {
        let typesToRead = Set([HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!])
        healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, error in
            completion(success, error)
        }
    }
    
    func getEnergyBurned(completion: @escaping (Double, Error?) -> Void) {
        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.date(byAdding: .day, value: -7, to: Date())!, end: Date(), options: .strictStartDate)
        let query = HKSampleQuery(sampleType: energyQuantityType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            guard error == nil else {
                completion(0, error)
                return
            }
            
            let total = samples?.compactMap { $0 as? HKQuantitySample }.reduce(0) { $0 + $1.quantity.doubleValue(for: .kilocalorie()) }
            completion(total ?? 0, nil)
        }
        healthStore.execute(query)
    }
}

class CoreDataHelper {
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchStatistics() -> [Statistics] {
        let fetchRequest = NSFetchRequest<Statistics>(entityName: "Statistics")
        do {
            let results = try context.fetch(fetchRequest)
            return results
        } catch {
            print("Error fetching Statistics objects: \(error)")
            return []
        }
    }
}
