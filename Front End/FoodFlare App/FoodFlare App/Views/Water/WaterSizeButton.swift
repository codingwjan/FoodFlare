//
//  WaterSizeButton.swift
//  FoodFlare
//
//  Created by Jan Pink on 19.06.23.
//

import SwiftUI
import CoreData

struct WaterSizeButton: View {
    let iconName: String
    var waterAmount: Double  // Update waterAmount to Double
    let confirmationGenerator = UINotificationFeedbackGenerator()

    @Environment(\.managedObjectContext) var managedObjectContext
    
    var body: some View {
        Button {
            let waterStats = WaterStatistics(context: self.managedObjectContext)
            waterStats.waterAmount = self.waterAmount
            waterStats.date = Date()
            
            do {
                try self.managedObjectContext.save()
                confirmationGenerator.notificationOccurred(.success)
                print("\(iconName) with \(waterAmount) have been saved")
            } catch {
                print("Failed to save water amount: \(error)")
            }
        } label: {
        HStack {
                VStack(alignment: .leading) {
                    Image(systemName: iconName)
                        .foregroundColor(Color.white)
                        .font(.title)
                        .fontWeight(.bold)
                    Text(String("\(waterAmount) L"))
                        .foregroundColor(Color.white)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top)
                }
            }
            Spacer()
        }
        .frame(height: 100)  // Explicitly set the width and height
        .padding()
        .background(Color.cyan)
        .cornerRadius(15)
    }
}

struct WaterSizeButton_Previews: PreviewProvider {
    static var previews: some View {
        WaterSizeButton(iconName: "mug.fill", waterAmount: 0.25)
    }
}
