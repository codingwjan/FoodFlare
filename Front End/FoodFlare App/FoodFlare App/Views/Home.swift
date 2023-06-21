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
    @State private var pickerSelection: Int? = 1
    
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    @State private var waterAmount: Double = 0.5
    
    var body: some View {
        ScrollView {
            StatisticView()
            HistoryView()
        }
        .navigationBarTitle(titleAnimator.title, displayMode: .large)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
