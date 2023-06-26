//
//  HistoryView.swift
//  FoodFlare
//
//  Created by Jan Pink on 15.06.23.
//

import SwiftUI
import CoreData

struct HistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \History.date, ascending: false)],
        animation: .default)
    private var historyItems: FetchedResults<History>
    
    @FetchRequest(entity: FoodItem.entity(), sortDescriptors: [])
    private var foodItems: FetchedResults<FoodItem>
    
    
    @State private var showingClearAlert = false
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    
    private func deleteItem(_ item: History) {
        viewContext.delete(item)
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func saveItem(_ item: History) {
        let newStatistics = Statistics(context: viewContext)
        newStatistics.date = Date()
        newStatistics.foodName = item.foodName
        newStatistics.foodCategory = item.foodCategory
        
        if let foodItem = foodItems.first(where: { $0.foodName == item.foodName }) {
            newStatistics.foodCalories = foodItem.foodCalories
            newStatistics.foodSugar = foodItem.foodSugar
            newStatistics.foodCategoryColor = foodItem.foodCategoryColor
        }
        
        do {
            try viewContext.save()
            print("Saved new statistics item: \(newStatistics)")
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("History")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
            }
            
            ForEach(Array(historyItems).prefix(5), id: \.self) { item in
                NavigationLink(destination: HistoryItemView(detectedItemName: item.foodName ?? "--", date: item.date ?? Date(), shouldShowDetectedItemSheet: .constant(false), isNewDetection: .constant(false)))
                               {
                    HistoryWidget(foodName: item.foodName ?? "--", foodCategory: item.foodCategory ?? "--", date: item.date ?? Date())
                }
                               .foregroundStyle(Color.primary)
            }
                    

                }
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 17.0).stroke(.tertiary, lineWidth: 1))
                .padding(.top)
        
    }
}



struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
