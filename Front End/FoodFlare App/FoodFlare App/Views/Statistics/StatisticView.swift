import SwiftUI

struct StatisticView: View {
    @State private var lastSevenDaysData: [StatisticWidget.Day] = []
    
    var body: some View {
        VStack {
            HStack {
                Text("Statistic")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
            }
            VStack {
                StatisticWidget(lastSevenDaysData: lastSevenDaysData)
                HStack {
                    Text("Today")
                        .font(.footnote)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.top)
                Divider()
                HStack {
                    VStack(alignment: .leading) {
                        Text("Calories")
                        Text("1040 cal")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Sugar")
                        Text("390 g")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    Spacer()
                }
                HStack {
                    Text("This Week")
                        .font(.footnote)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.top)
                Divider()
                HStack {
                    VStack(alignment: .leading) {
                        Text("Calories")
                        Text("1040 cal")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Sugar")
                        Text("390 g")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    Spacer()
                }
            }
            .padding()
            .background(.quaternary)
            .cornerRadius(15)
        }
        .padding()
        .onAppear(perform: loadData)
    }

    private func loadData() {
        let calendar = Calendar.current
        var currentDate = calendar.startOfDay(for: Date())

        for _ in 1...7 {
            let startOfDay = currentDate
            let totalCalories = Int16.random(in: 500...2500)
            lastSevenDaysData.append(StatisticWidget.Day(id: startOfDay, totalCalories: totalCalories))
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        }

        lastSevenDaysData = lastSevenDaysData.reversed()
    }
}

struct StatisticView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticView()
    }
}
