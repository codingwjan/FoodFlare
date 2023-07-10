//
//  ManualItemAddView.swift
//  FoodFlare
//
//  Created by Jan Pink on 19.06.23.
//

import SwiftUI

struct ManualItemAddView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FoodItem.foodName, ascending: true)],
        animation: .default)
    private var foodItems: FetchedResults<FoodItem>
    
    @State private var searchText = ""  // Search text state
    @State private var toggleState: Bool = false
    
    private func deleteItem(_ item: FoodItem) {
        viewContext.delete(item)
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func favoriteItem(_ item: FoodItem) {
        item.isFavourite.toggle()
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    var body: some View {
        List {
            // Filter items based on search text
            let filteredItems = foodItems.filter {
                searchText.isEmpty || $0.foodName?.localizedCaseInsensitiveContains(searchText) == true
            }
            
            // Group items by their starting letter
            let groupedItems = Dictionary(grouping: filteredItems) { (element: FoodItem)  in
                return String(element.foodName?.prefix(1).uppercased() ?? "#")
            }
            
            Toggle(isOn: $toggleState) {
                Text("Favorties only")
            }
            
            ForEach(groupedItems.keys.sorted(), id: \.self) { key in
                if let items = groupedItems[key] {
                    let filteredItems = toggleState ? items.filter { $0.isFavourite } : items
                    SectionView(title: key, items: filteredItems, deleteAction: deleteItem, favoriteAction: favoriteItem, toggleState: toggleState)
                }
            }
        }
        .searchable(text: $searchText)  // SwiftUI's built-in search bar
        .navigationTitle("Food")
        .navigationBarTitleDisplayMode(.large)
        .toolbar{
            NavigationLink(destination: AddCustomItem(foodName: "", foodCategory: "", foodCalories: 10, foodSugar: 10)) {
                Image(systemName: "plus")
            }
        }
    }
}

struct SectionView: View {
    let title: String
    let items: [FoodItem]
    let deleteAction: (FoodItem) -> Void
    let favoriteAction: (FoodItem) -> Void  // Declare favoriteAction here
    let toggleState: Bool
    
    var body: some View {
        if (!toggleState) {
            Section(header: Text(title)) {
                ForEach(items, id: \.self) { item in
                    NavigationLink {
                        HistoryItemView(detectedItemName: item.foodName ?? "--", date: Date(), shouldShowDetectedItemSheet: .constant(false), isNewDetection: .constant(false))
                    } label: {
                        HStack {
                            Text(item.foodName ?? "")
                                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                    Button {
                                        favoriteAction(item)  // Use favoriteAction here
                                    } label: {
                                        Label ("Favorite", systemImage: item.isFavourite ? "heart.fill" : "heart")  // Use isFavourite to conditionally render the heart
                                    }
                                    
                                }
                                .tint(Color.orange)
                            Spacer()
                            if(item.isFavourite) {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(Color.orange)
                            }
                        }
                    }
                }
            }
        } else {
            ForEach(items, id: \.self) { item in
                NavigationLink {
                    HistoryItemView(detectedItemName: item.foodName ?? "--", date: Date(), shouldShowDetectedItemSheet: .constant(false), isNewDetection: .constant(false))
                } label: {
                    HStack {
                        Text(item.foodName ?? "")
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    deleteAction(item)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .tint(Color.red)
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button {
                                    favoriteAction(item)  // Use favoriteAction here
                                } label: {
                                    Label ("Favorite", systemImage: item.isFavourite ? "heart.fill" : "heart")  // Use isFavourite to conditionally render the heart
                                }
                                
                            }
                            .tint(Color.orange)
                        Spacer()
                        if(item.isFavourite) {
                            Image(systemName: "heart.fill")
                                .foregroundColor(Color.orange)
                        }
                    }
                }
                
            }
        }
    }
}

// Not able to provide correct PreviewProvider here because FoodItem instances can't be created without a managedObjectContext.
struct ManualItemAddView_Previews: PreviewProvider {
    static var previews: some View {
        ManualItemAddView()
    }
}
