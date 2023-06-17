import SwiftUI
import CoreData

struct FullHistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \History.date, ascending: false)],
        animation: .default)
    private var historyItems: FetchedResults<History>
    
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
                // Group items by date
                let groupedItems = Dictionary(grouping: historyItems) { (element: History)  in
                    return Calendar.current.startOfDay(for: element.date ?? Date())
                }
                
                ForEach(groupedItems.sorted(by: { $0.key > $1.key }), id: \.key) { key, values in
                    Section(header: Text("\(key, formatter: itemFormatter)")) {
                        ForEach(values, id: \.self) { item in
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
