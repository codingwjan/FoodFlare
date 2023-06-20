//
//  DeveloperView.swift
//  FoodFlare
//
//  Created by Jan Pink on 20.06.23.
//

import SwiftUI
import CoreData

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

                print("Food Item: \(foodItem.foodName ?? ""), Category: \(foodItem.foodCategory ?? ""), Calories: \(foodItem.foodCalories), Sugar: \(foodItem.foodSugar) Color: \(foodItem.foodCategoryColor)")
            }

            try context.save()
            print("Data saved to Core Data.")
        } catch {
            print("Failed to load data from JSON: \(error)")
        }
    }
}

struct DeveloperView_Previews: PreviewProvider {
    static var previews: some View {
        DeveloperView()
    }
}
