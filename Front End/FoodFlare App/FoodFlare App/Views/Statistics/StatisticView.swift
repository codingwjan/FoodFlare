import SwiftUI
import Charts

struct StatisticView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Statistics.date, ascending: false)],
        animation: .default)
    
    private var statisticItems: FetchedResults<Statistics>

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE" // day of the week
        return formatter
    }()
    
    var body: some View {
        VStack {
            HStack {
                Text("Statistic")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
            }
            VStack {
                Chart {
                    ForEach(statisticItems, id: \.self) { statistic in
                        BarMark(
                            x: .value("Day", dateFormatter.string(from: statistic.date ?? Date())),
                            y: .value("Calories", Double(statistic.foodCalories))
                        )
                        .foregroundStyle(by: .value("Shape Color", statistic.foodCategoryColor ?? ""))
                    }
                }
                .chartForegroundStyleScale([
                    "Green": .green, "Yellow": .yellow, "Red": .red
                ])
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
    }
}

struct StatisticView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticView()
    }
}
