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
    
    @State private var showingClearAlert = false
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    
    var body: some View {
        VStack {
            HStack {
                Text("History")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                if !historyItems.isEmpty {
                    Button(action: {
                        showingClearAlert = true
                        feedbackGenerator.impactOccurred()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            feedbackGenerator.impactOccurred()
                            
                        }
                    }, label: {
                        Text("Clear history")
                    })
                    .alert(isPresented: $showingClearAlert) {
                        Alert(
                            title: Text("Clear History"),
                            message: Text("Are you sure you want to clear your history? This action cannot be undone."),
                            primaryButton: .destructive(Text("Delete")) {
                                for item in historyItems {
                                    viewContext.delete(item)
                                }
                                do {
                                    try viewContext.save()
                                } catch {
                                    let nsError = error as NSError
                                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                }
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
            }
            ForEach(Array(historyItems), id: \.objectID) { item in
                HistoryWidget(foodName: item.foodName ?? "", foodCategory: item.foodCategory ?? "", date: item.date ?? Date())
            }
        }
        .padding()
    }
}



struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
