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

    @State var lastSevenDaysData: [StatisticWidget.Day] = []

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
        .onAppear {
            calculateLastSevenDays()
        }
    }
    
    func calculateLastSevenDays() {
        // Get current date and start of day
        let calendar = Calendar.current
        var currentDate = calendar.startOfDay(for: Date())
        // Array to hold last seven days' data
        var data: [StatisticWidget.Day] = []
        // For each of the last seven days
        for _ in 1...7 {
            // Calculate the start and end of the day
            let startOfDay = currentDate
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            // Filter the statistics items for the current day
            let dayItems = statisticsItems.filter {
                $0.date! >= startOfDay && $0.date! < endOfDay
            }
            // Calculate the total calories
            let totalCalories = dayItems.reduce(into: 0) { $0 + $1.foodCalories }
            // Get the day name
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"  // Day of the week, e.g. "Wednesday"
            let dayName = formatter.string(from: currentDate)
            // Add the data to the array
            data.append(StatisticWidget.Day(id: startOfDay, dayName: dayName, totalCalories: totalCalories))
            // Move to the previous day
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        }
        // Assign the calculated data
        lastSevenDaysData = data.reversed()  // Reverse the array to show the oldest day first
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
