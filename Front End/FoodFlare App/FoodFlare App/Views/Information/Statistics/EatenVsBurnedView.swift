import SwiftUI
import Charts
import HealthKit
import CoreData

struct EatenVsBurnedView: View {
    @Environment(\.managedObjectContext) private var viewContext
    private var healthKitHelper = HealthKitHelper()
    @State private var coreDataHelper: CoreDataHelper!
    
    @State private var burnedData: [BurnedData] = [] // Create an array to hold burned data over time
    @State private var eatenData: [ProfitData] = []
    @State private var totalEatenData: Double = 0
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE" // day of the week
        return formatter
    }()
       
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                if totalEatenData > burnedData.reduce(0, {$0 + $1.energy}) {
                    Text("This week you gained calories.")
                    HStack {
                        Image(systemName: "arrow.up")
                            .foregroundColor(Color.gray)
                        Text("\(totalEatenData - burnedData.reduce(0, {$0 + $1.energy}), specifier: "%.0f") cal")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                } else {
                    Text("This week you lost calories.")
                    HStack {
                        Image(systemName: "arrow.down")
                            .foregroundColor(Color.gray)
                        Text("\((totalEatenData - burnedData.reduce(0, {$0 + $1.energy})).magnitude, specifier: "%.0f") cal") // Use .magnitude for absolute value
                            .font(.title)
                            .fontWeight(.bold)
                    }
                }
                Chart {
                    ForEach(eatenData.indices, id: \.self) { index in
                        if index < burnedData.count {
                            LineMark(
                                x: .value("Day", dateFormatter.string(from: eatenData[index].date)),
                                y: .value("Eaten", eatenData[index].profit),
                                series: .value("Type", "Eaten")
                            )
                            .foregroundStyle(.blue)

                            LineMark(
                                x: .value("Day", dateFormatter.string(from: burnedData[index].date)),
                                y: .value("Burned", burnedData[index].energy),
                                series: .value("Type", "Burned")
                            )
                            .foregroundStyle(.red)
                        }
                    }
                }
                .frame(height: 400)
            }
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 17.0).stroke(.tertiary, lineWidth: 1))
        }
        .padding(.top)
        .onAppear(perform: {
            coreDataHelper = CoreDataHelper(context: viewContext)
            fetchData()
        })
    }
    
    private func fetchData() {
        // Start and end dates for the last seven days
        let endDate = Calendar.current.startOfDay(for: Date())
        guard let startDate = Calendar.current.date(byAdding: .day, value: -6, to: endDate) else { return }

        healthKitHelper.authorizeHealthKit { success, error in
            if success {
                healthKitHelper.getEnergyBurned(startDate: startDate, endDate: endDate) { energyData, error in
                    DispatchQueue.main.async {
                        self.burnedData = energyData
                    }
                }
            } else if let error = error {
                print("HealthKit authorization failed with error: \(error)")
            }
        }
        
        let statistics = coreDataHelper.fetchStatistics(from: startDate, to: endDate)
        self.eatenData = statistics.map {
            ProfitData(date: Calendar.current.startOfDay(for: $0.date!), profit: Double($0.foodCalories))
        }
        self.totalEatenData = eatenData.reduce(0) { $0 + $1.profit }
    }

    
    // A function to divide the total burned energy into daily values.
    private func divideTotalBurned(burnedEnergy: Double, startDate: Date) -> [BurnedData] {
        var burnedData: [BurnedData] = []
        let dailyBurned = burnedEnergy / 7

        for i in 0..<7 {
            let date = Calendar.current.date(byAdding: .day, value: i, to: startDate)!
            burnedData.append(BurnedData(date: date, energy: dailyBurned))
        }

        return burnedData
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

struct BurnedData { // A structure to hold burned data over time
    let date: Date
    let energy: Double
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
    
    func getEnergyBurned(startDate: Date, endDate: Date, completion: @escaping ([BurnedData], Error?) -> Void) {
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKSampleQuery(sampleType: energyQuantityType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            guard error == nil else {
                completion([], error)
                return
            }
            
            let data = samples?.compactMap { sample -> BurnedData? in
                if let sample = sample as? HKQuantitySample {
                    let energy = sample.quantity.doubleValue(for: .kilocalorie())
                    return BurnedData(date: sample.startDate, energy: energy)
                }
                return nil
            }
            
            completion(data ?? [], nil)
        }
        healthStore.execute(query)
    }
}

class CoreDataHelper {
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchStatistics(from startDate: Date, to endDate: Date) -> [Statistics] {
        let fetchRequest = NSFetchRequest<Statistics>(entityName: "Statistics")
        fetchRequest.predicate = NSPredicate(format: "(date >= %@) AND (date < %@)", startDate as NSDate, endDate as NSDate)
        do {
            let results = try context.fetch(fetchRequest)
            return results
        } catch {
            print("Error fetching Statistics objects: \(error)")
            return []
        }
    }
}
