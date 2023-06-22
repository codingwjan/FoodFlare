//
//  CreateButton.swift
//  FoodFlare App
//
//  Created by Jan Pink on 13.06.23.
//

import SwiftUI
import CoreData
import UIKit

struct CreateButton: View {
    // Create a medium impact feedback generator
    private let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    @Binding var foodName: String
    @Binding var foodCategory: String
    @Binding var foodCalories: Int16
    @Binding var foodSugar: Int16

    var managedObjectContext: NSManagedObjectContext

    var body: some View {
        HStack {
            Button(action: {
                print("Eat and Save button has been pressed")
                self.impactGenerator.impactOccurred()

                let foodItem = FoodItem(context: self.managedObjectContext)
                foodItem.foodName = self.foodName
                foodItem.foodCategory = self.foodCategory
                foodItem.foodCalories = self.foodCalories
                foodItem.foodSugar = self.foodSugar

                let statistic = Statistics(context: self.managedObjectContext)
                statistic.foodName = self.foodName
                statistic.foodCategory = self.foodCategory
                statistic.foodCalories = self.foodCalories
                statistic.foodSugar = self.foodSugar
                statistic.date = Date() // Current date
                statistic.foodCategoryColor = "Blue" // You can change this based on your needs

                do {
                    try self.managedObjectContext.save()
                } catch {
                    print(error)
                }
            }) {
                Spacer()
                Text("Eat and Save")
                    .font(.system(size: 20, weight: .regular, design: .default))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.vertical, 15.0)
            .background(Color.blue)
            .cornerRadius(17.0)
            .frame(maxWidth: .infinity)
            
            Button(action: {
                print("Save button has been pressed")
                self.impactGenerator.impactOccurred()

                let foodItem = FoodItem(context: self.managedObjectContext)
                foodItem.foodName = self.foodName
                foodItem.foodCategory = self.foodCategory
                foodItem.foodCalories = self.foodCalories
                foodItem.foodSugar = self.foodSugar

                do {
                    try self.managedObjectContext.save()
                } catch {
                    print(error)
                }
            }) {
                Spacer()
                Text("Save")
                    .font(.system(size: 20, weight: .regular, design: .default))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.vertical, 15.0)
            .background(.secondary)
            .cornerRadius(17.0)
            .frame(maxWidth: .infinity)
        }
    }
}

struct CreateButton_Previews: PreviewProvider {
    static var previews: some View {
        CreateButton(foodName: .constant(""), foodCategory: .constant(""), foodCalories: .constant(10), foodSugar: .constant(10), managedObjectContext: NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType))
    }
}
