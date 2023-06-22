//
//  DeveloperView.swift
//  FoodFlare
//
//  Created by Jan Pink on 20.06.23.
//

import SwiftUI
import CoreData
import UserNotifications

struct DeveloperView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        VStack {
            Button("Delete All") {
                deleteEntity(entityName: "Fooditem")
                deleteEntity(entityName: "History")
                deleteEntity(entityName: "Statistics")
                deleteEntity(entityName: "WaterStatistics")
            }
            .padding()
            Button("Delete History") {
                deleteEntity(entityName: "History")
            }
            .padding()
            Button("Delete Food Data") {
                deleteEntity(entityName: "FoodItem")
            }
            .padding()
            Button("Delete Water Statistics") {
                deleteEntity(entityName: "WaterStatistics")
            }
            .padding()
            Button("Delete Food Statistics") {
                deleteEntity(entityName: "Statistics")
            }
            .padding()
            Button("Load Food Data") {
                loadData()
            }
            .padding()
            Button("Demo Notification") {
                checkForPermission()
            }
            .padding()
            Button("Start Live Activity") {
                print("would start live activity")
            }
            .padding()
        }
    }
    
    func deleteEntity(entityName: String) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try viewContext.execute(deleteRequest)
            try viewContext.save()
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func loadData() {
        let persistenceController = PersistenceController.shared
        guard let url = Bundle.main.url(forResource: "defaultData", withExtension: "json") else {
            print("Failed to locate defaultData.json in app bundle.")
            return
        }
        
        print("Found defaultData.json in app bundle.")
        
        let context = persistenceController.container.viewContext
        
        do {
            let data = try Data(contentsOf: url)
            let jsonResult = try JSONSerialization.jsonObject(with: data) as! [String: Any]
            let foodItemsArray = jsonResult["foodItems"] as! [[String: Any]]
            
            for foodItemDict in foodItemsArray {
                let foodItem = FoodItem(context: context)
                foodItem.foodName = foodItemDict["foodName"] as? String
                foodItem.foodCategory = foodItemDict["foodCategory"] as? String
                foodItem.foodCalories = foodItemDict["foodCalories"] as? Int16 ?? 0
                foodItem.foodSugar = foodItemDict["foodSugar"] as? Int16 ?? 0
                foodItem.foodDescription = foodItemDict["foodDescription"] as? String
                foodItem.foodCategoryColor = foodItemDict["foodCategoryColor"] as? String
                foodItem.foodAmountMatters = foodItemDict["foodAmountMatters"] as? Bool ?? false
                
                print("Food Item: \(foodItem.foodName ?? ""), Category: \(foodItem.foodCategory ?? ""), Calories: \(foodItem.foodCalories), Sugar: \(foodItem.foodSugar) Color: \(foodItem.foodCategoryColor ?? "")")
            }
            
            try context.save()
            print("Data saved to Core Data.")
        } catch {
            print("Failed to load data from JSON: \(error)")
        }
    }
    
    func sendNotification1() {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Hello!"
        content.body = "It's 11:05 AM."
        content.sound = .defaultRingtone
        
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        dateComponents.hour = 11
        dateComponents.minute = 10
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        center.add(request)
    }
    func sendNotification2() {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Hello!"
        content.body = "It's 11:05 AM."
        content.sound = .defaultCritical
        
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        dateComponents.hour = 11
        dateComponents.minute = 11
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        center.add(request)
    }
    func sendNotification3() {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Hello!"
        content.body = "It's 11:05 AM."
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        dateComponents.hour = 11
        dateComponents.minute = 12
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        center.add(request)
    }
    
    func checkForPermission() {
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                DispatchQueue.main.async {
                    self.sendNotification1()
                    self.sendNotification2()
                    self.sendNotification3()
                }
            } else {
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if granted {
                        DispatchQueue.main.async {
                            self.sendNotification1()
                            self.sendNotification2()
                            self.sendNotification3()
                        }
                    } else if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}
    
    struct DeveloperView_Previews: PreviewProvider {
        static var previews: some View {
            DeveloperView()
        }
    }
