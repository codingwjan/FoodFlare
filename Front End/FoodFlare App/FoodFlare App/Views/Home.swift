import SwiftUI
import Combine

class TitleAnimator: ObservableObject {
    @Published var title: String = ""
    private var counter = 0
    let fullTitle = "FoodFlare"
    let timer = Timer.publish(every: 0.07, on: .main, in: .common).autoconnect()
    private var cancellables = Set<AnyCancellable>()
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)
    
    init() {
        timer
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.counter < self.fullTitle.count {
                    self.counter += 1
                    self.title = String(self.fullTitle.prefix(self.counter))
                    self.feedbackGenerator.impactOccurred()
                }
            }
            .store(in: &cancellables)
    }
}

struct Home: View {
    @StateObject private var titleAnimator = TitleAnimator()
    
    var body: some View {
        VStack {
            Text(titleAnimator.title) // Animated Title
                .font(.largeTitle) // Make the font large
                .fontWeight(.bold) // Make the font bold
                .padding(.top) // Add padding to the top
            ScrollView {
                StatisticView()
                HistoryView()
                
            }
            Spacer() // This will push the CreateButton down.
            CreateButton()
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity) // Make VStack take up full width
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
