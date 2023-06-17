import SwiftUI
import CoreData

@main
struct FoodFlare_AppApp: App {
    let persistenceController = PersistenceController.shared

    init() {
        print("App Init")
        if isFirstLaunch() {
            print("First Launch Detected")
            loadData()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }

    func isFirstLaunch() -> Bool {
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            print("App has been launched before.")
            return true
        } else {
            print("App has not been launched before.")
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            return true
        }
    }


    func loadData() {
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
