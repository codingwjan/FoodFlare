import SwiftUI
import CoreData
import HealthKit

struct AddWaterView: View {
    @Binding var waterAmount: Double
    let generatorLight = UIImpactFeedbackGenerator(style: .light)
    let generatorHeavy = UIImpactFeedbackGenerator(style: .heavy)
    let confirmationGenerator = UINotificationFeedbackGenerator()
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @State private var showConfirmation = false
    
    private let healthStore = HKHealthStore()
    
    private func saveWaterToHealthKit() {
        // Convert waterAmount to liters (HealthKit uses liter units)
        let waterQuantity = HKQuantity(unit: .liter(), doubleValue: waterAmount)
        let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater)!
        let now = Date()
        let waterSample = HKQuantitySample(type: waterType, quantity: waterQuantity, start: now, end: now)
        
        healthStore.save(waterSample) { success, error in
            if success {
                print("Successfully saved water to HealthKit")
            } else if let error = error {
                print("Failed to save water to HealthKit: \(error)")
            }
        }
    }
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                
                Text("\(String(format: "%.2f", waterAmount)) L")
                    .font(.title)
                
                Slider(value: $waterAmount, in: 0...2, step: 0.05, onEditingChanged: { _ in
                    let roundedValue = (waterAmount * 100).rounded() / 100
                    waterAmount = roundedValue
                    
                    if roundedValue.truncatingRemainder(dividingBy: 0.05) == 0 {
                        generatorLight.impactOccurred()
                    }
                    
                    if roundedValue.truncatingRemainder(dividingBy: 0.25) == 0 {
                        generatorHeavy.impactOccurred()
                    }
                })
                .accentColor(.blue)
                .padding(.top, 20)
                
                Button(action: {
                    let waterStats = WaterStatistics(context: self.managedObjectContext)
                    waterStats.waterAmount = self.waterAmount
                    waterStats.date = Date()
                    
                    do {
                        try self.managedObjectContext.save()
                        self.showConfirmation = true
                        confirmationGenerator.notificationOccurred(.success)
                        saveWaterToHealthKit()
                    } catch {
                        print("Failed to save water amount: \(error)")
                    }
                }) {
                    Text("Add Water")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
                .alert(isPresented: $showConfirmation) {
                    Alert(title: Text("Saved Successfully"), message: Text("Your water consumption has been saved."), dismissButton: .default(Text("OK")))
                }
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Water")
        .navigationBarTitleDisplayMode(.large)
    }
}


struct AddWaterView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }

    struct PreviewWrapper: View {
        @State(initialValue: 0.5) var testWaterAmount: Double

        var body: some View {
            AddWaterView(waterAmount: $testWaterAmount)
        }
    }
}
