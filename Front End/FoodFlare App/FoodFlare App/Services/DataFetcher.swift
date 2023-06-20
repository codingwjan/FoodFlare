//
//  DataFetcher.swift
//  FoodFlare
//
//  Created by Jan Pink on 20.06.23.
//

import Foundation
import CoreData
import HealthKit

class DataFetcher {
    
    static let shared = DataFetcher()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Statistics")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // Create a HealthKit store
    let healthStore = HKHealthStore()
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let typesToRead: Set = [HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!]
        
        healthStore.requestAuthorization(toShare: [], read: typesToRead) { (success, error) in
            completion(success)
        }
    }
    
    func fetchTodayCalories(completion: @escaping (Int) -> Void) {
        print("fetching today calories")
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Statistics")
        let startOfToday = Calendar.current.startOfDay(for: Date())
        fetchRequest.predicate = NSPredicate(format: "date >= %@", startOfToday as NSDate)
        
        do {
            if let result = try context.fetch(fetchRequest) as? [NSManagedObject] {
                let totalCalories = result.reduce(0) { $0 + ($1.value(forKey: "foodCalories") as? Int ?? 0) }
                completion(totalCalories)
                print(totalCalories)
            }
        } catch {
            print("Failed to fetch Statistics: \(error)")
            completion(0)
        }
    }
    
    func fetchBurnedCalories(completion: @escaping (Double) -> Void) {
        print("fetching burned calories")
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
                    completion(value)
                }
            } else {
                print("Failed to fetch burned calories = \(error?.localizedDescription ?? "N/A")")
                completion(0.0)
            }
        }
        
        healthStore.execute(query)
    }
}
