//
//  StatisticView.swift
//  FoodFlare
//
//  Created by Jan Pink on 16.06.23.
//

import SwiftUI
import CoreData

struct StatisticView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Statistics.date, ascending: true)],
        animation: .default)
    private var statisticsItems: FetchedResults<Statistics>

    @State private var changeCount = 0  // For observing CoreData changes

    var lastSevenDaysData: [StatisticWidget.Day] {
        var data: [StatisticWidget.Day] = []
        let calendar = Calendar.current
        var currentDate = calendar.startOfDay(for: Date())
        
        for _ in 1...7 {
            let startOfDay = currentDate
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            
            let dayItems = statisticsItems.filter {
                $0.date! >= startOfDay && $0.date! < endOfDay
            }
            
            let totalCalories = dayItems.reduce(into: 0) { $0 + $1.foodCalories }
            data.append(StatisticWidget.Day(id: startOfDay, totalCalories: totalCalories))
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        }
        
        return data.reversed()
    }

    var body: some View {
        VStack {
            HStack {
                Text("Statistic")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
            }
            StatisticWidget(lastSevenDaysData: lastSevenDaysData)
        }
        .padding()
        .onChange(of: changeCount) { _ in }
        // To force SwiftUI to recalculate when the CoreData items change
        ForEach(statisticsItems, id: \.objectID) { _ in
            EmptyView()
        }
        .onAppear {
            changeCount += 1
        }
    }
}

    
struct StatisticView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        for i in 1...7 {
            let newItem = Statistics(context: viewContext)
            newItem.date = Calendar.current.date(byAdding: .day, value: -i, to: Date())
            newItem.foodCalories = Int16.random(in: 500...2500)
            newItem.foodName = "Test Food \(i)"
            newItem.foodCategory = "Test Category \(i)"
            newItem.foodSugar = Int16.random(in: 1...50)
        }
        
        return StatisticView().environment(\.managedObjectContext, viewContext)
    }
}
