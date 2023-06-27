//
//  TodayView.swift
//  FoodFlare
//
//  Created by Jan Pink on 18.06.23.
//

import SwiftUI
import HealthKit

struct TodayView: View {
    let todayCalories: Int
    let todayBurned: String
    let todaySugar: Int
    let todaySugarGoal: Int
    let overviewShowMore: Bool
    
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("\(Date(), formatter: DateFormatter.day)")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                if (overviewShowMore == true) {
                    NavigationLink {
                        StatisticView()
                    } label: {
                        Text("Show more")
                    }
                }
            }
                
            HStack {
                Text("Calories")
                    .frame(width: 70, alignment: .leading)
                Spacer()
                HStack(alignment: .center, spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("Eaten")
                            .foregroundColor(.secondary)
                            .frame(width: 80, alignment: .leading)
                        Text("\(todayCalories)")
                            .font(.title)
                            .fontWeight(.semibold)
                    }
                    VStack(alignment: .leading) {
                        Text("Burned")
                            .foregroundColor(.secondary)
                            .frame(width: 80, alignment: .leading)
                        Text("\(todayBurned)")
                            .font(.title)
                            .fontWeight(.semibold)
                    }
                }
            }
            .padding(.top)

            HStack {
                Text("Sugar")
                    .frame(width: 70, alignment: .leading)
                Spacer()
                HStack(alignment: .center, spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("Eaten")
                            .foregroundColor(.secondary)
                            .frame(width: 80, alignment: .leading)
                        Text("\(todaySugar)")
                            .font(.title)
                            .fontWeight(.semibold)
                    }
                    VStack(alignment: .leading) {
                        Text("Goal")
                            .foregroundColor(.secondary)
                            .frame(width: 80, alignment: .leading)
                        Text("\(todaySugarGoal)")
                            .font(.title)
                            .fontWeight(.semibold)
                    }
                }
            }
            .padding(.top)
        }
        .padding()
        .overlay(RoundedRectangle(cornerRadius: 17.0).stroke(.tertiary, lineWidth: 1))

    }
}

extension DateFormatter {
    static var day: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE" // EEEE format for full day name
        return formatter
    }
}


struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        TodayView(todayCalories: 15, todayBurned: "12", todaySugar: 15, todaySugarGoal: 5, overviewShowMore: false)
    }
}
