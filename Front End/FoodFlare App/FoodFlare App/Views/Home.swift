import SwiftUI
import Combine
import CoreData

class TitleAnimator: ObservableObject {
    @Published var title: String = ""
    private var counter = 0
    let fullTitle = "FoodFlare"
    let timer = Timer.publish(every: 0.07, on: .main, in: .common).autoconnect()
    private var cancellables = Set<AnyCancellable>()
    let feedbackGeneratorSoft = UIImpactFeedbackGenerator(style: .soft)
    
    init() {
        timer
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.counter < self.fullTitle.count {
                    self.counter += 1
                    self.title = String(self.fullTitle.prefix(self.counter))
                    self.feedbackGeneratorSoft.impactOccurred()
                }
            }
            .store(in: &cancellables)
    }
}

struct Home: View {
    let feedbackGeneratorMedium = UIImpactFeedbackGenerator(style: .medium)
    @StateObject private var titleAnimator = TitleAnimator()
    
    @State private var showingActionSheet = false
    @State private var pickerSelection = 1
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    func deleteAllData() {
        let entities = ["History", "Statistics", "WaterStatistics", "FoodItem"]
        for entity in entities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try managedObjectContext.execute(deleteRequest)
            } catch let error as NSError {
                print("Error: \(error.localizedDescription)")
                return
            }
        }
    }
    
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    StatisticView()
                    HistoryView()
                    
                }
                Spacer() // This will push the CreateButton down.
                CreateButton()
                    .padding(.horizontal)
            }
            .frame(maxWidth: .infinity) // Make VStack take up full width
            .toolbar(content: {
                Button(action: {
                    feedbackGeneratorMedium.impactOccurred()
                    showingActionSheet = true
                }) {
                    Image(systemName: "ellipsis")
                }
            })
            .actionSheet(isPresented: $showingActionSheet) {
                ActionSheet(title: Text("Select an option"), buttons: [
                    .default(Text("Add Food"), action: { pickerSelection = 1 }),
                    .default(Text("Add Liquid"), action: { pickerSelection = 2 }),
                    .default(Text("Add Weight"), action: { pickerSelection = 3 }),
                    .default(Text("Delete Data"), action: {
                        pickerSelection = 4
                        deleteAllData()
                    }),
                    .cancel()
                ])
            }
            .navigationTitle(titleAnimator.title)
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
