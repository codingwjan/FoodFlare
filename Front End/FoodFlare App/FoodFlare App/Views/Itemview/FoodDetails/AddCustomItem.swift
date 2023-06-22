//
//  AddCustomItem.swift
//  FoodFlare
//
//  Created by Jan Pink on 22.06.23.
//

import SwiftUI
import CoreData

extension View {
    func endEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct AddCustomItem: View {
    @Environment(\.managedObjectContext) var managedObjectContext

    @State var foodName: String = ""
    @State var foodCategory: String = ""
    @State var foodCalories: Int16 = 10
    @State var foodSugar: Int16 = 10
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                TextField("Food Name", text: $foodName)
                    .padding()
                    .background(.tertiary)
                    .cornerRadius(15)
                    .padding(.top)
                TextField("Food Category", text: $foodCategory)
                    .padding()
                    .background(.tertiary)
                    .cornerRadius(15)
                Stepper(value: $foodCalories, in: 10...1000, step: 10) {
                    Text("Food Calories: \(foodCalories) cal")
                }
                .padding()
                .background(.tertiary)
                .cornerRadius(15)
                Stepper(value: $foodSugar, in: 10...1000, step: 10) {
                    Text("Food Sugar: \(foodSugar) g")
                }
                .padding()
                .background(.tertiary)
                .cornerRadius(15)
                .padding(.bottom)
                CreateButton(foodName: $foodName, foodCategory: $foodCategory, foodCalories: $foodCalories, foodSugar: $foodSugar, managedObjectContext: managedObjectContext)
            }
            .padding() // You might also want some padding
        }
        .scrollDismissesKeyboard(.interactively) // Dismiss the keyboard when dragging begins
        .navigationTitle("Add Food")
    }
}

struct AddCustomItem_Previews: PreviewProvider {
    static var previews: some View {
        AddCustomItem()
    }
}
