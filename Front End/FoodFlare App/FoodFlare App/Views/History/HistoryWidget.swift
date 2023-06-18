//
//  HistoryWidget.swift
//  FoodFlare App
//
//  Created by Jan Pink on 13.06.23.
//

import SwiftUI

struct HistoryWidget: View {
    var foodName: String
    var foodCategory: String
    var date: Date
    
    func imageExists(_ imageName: String) -> Bool {
        return UIImage(named: imageName) != nil
    }

    var body: some View {
        let formattedFoodName = foodName.replacingOccurrences(of: "_", with: " ").capitalized
        let formattedFoodCategory = foodCategory.replacingOccurrences(of: "_", with: " ").capitalized

        HStack {
            Image(imageExists(foodName) ? foodName : "default")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 105.0, height: 70)
                .clipped()
                .cornerRadius(16)
            VStack(alignment: .leading) {
                Text(formattedFoodName)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                Text(formattedFoodCategory)
                    .fontWeight(.light)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
            HStack {
                Text("\(date, formatter: DateFormatter.onlyDate)") // format the date to a readable string
                Image(systemName: "chevron.right")
            }
        }
        .padding(10.0)
        .background(.quaternary)
        .cornerRadius(20)
        .onAppear {
            print("HistoryWidget appeared with foodName: \(formattedFoodName), foodCategory: \(formattedFoodCategory), date: \(date)")
        }
    }
}

struct HistoryWidget_Previews: PreviewProvider {
    static var previews: some View {
        HistoryWidget(foodName: "white", foodCategory: "Fruit", date: Date())
    }
}

extension DateFormatter {
    static let onlyDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
}
