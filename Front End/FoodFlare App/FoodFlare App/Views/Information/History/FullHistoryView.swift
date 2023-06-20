import SwiftUI
import CoreData

struct FullHistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \History.date, ascending: false)],
        animation: .default)
    private var historyItems: FetchedResults<History>

    @State private var searchText = ""  // Search text state

    private func deleteItem(_ item: History) {
        viewContext.delete(item)
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    var body: some View {
            List {
                // Filter items based on search text
                let filteredItems = historyItems.filter {
                    searchText.isEmpty || $0.foodName?.localizedCaseInsensitiveContains(searchText) == true
                }
                
                // Group items by date
                let groupedItems = Dictionary(grouping: filteredItems) { (element: History)  in
                    return Calendar.current.startOfDay(for: element.date ?? Date())
                }
                
                ForEach(groupedItems.sorted(by: { $0.key > $1.key }), id: \.key) { key, values in
                    Section(header: Text("\(key, formatter: itemFormatter)")) {
                        ForEach(values, id: \.self) { item in
                            NavigationLink(destination: HistoryItemView(detectedItemName: item.foodName ?? "--", date: item.date ?? Date(), shouldShowDetectedItemSheet: .constant(false), isNewDetection: .constant(false))) {
                                Text(item.foodName ?? "")
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            deleteItem(item)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }
                }
            }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText)  // SwiftUI's built-in search bar
    }
    
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

struct FullHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        FullHistoryView()
    }
}
