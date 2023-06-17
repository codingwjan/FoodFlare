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
    


    var body: some View {
        HStack {
            Image(foodName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 105.0, height: 70)
                .clipped()
                .cornerRadius(16)
            VStack(alignment: .leading) {
                Text(foodName)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .textInputAutocapitalization(.words)
                Text(foodCategory)
                    .fontWeight(.light)
                    .foregroundColor(.secondary)
                    .textInputAutocapitalization(.words)
                    
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
            print("HistoryWidget appeared with foodName: \(foodName), foodCategory: \(foodCategory), date: \(date)")
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
