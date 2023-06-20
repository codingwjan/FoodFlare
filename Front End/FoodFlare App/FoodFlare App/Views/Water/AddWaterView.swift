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
            ScrollView {
                Spacer()
                    HStack {
                        Button(action: {
                            generatorLight.impactOccurred()
                            self.waterAmount = max(self.waterAmount - 0.05, 0)
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Color.secondary)
                        }
                        .gesture(LongPressGesture(minimumDuration: 0.5).onEnded {_ in
                            generatorLight.impactOccurred()
                            self.waterAmount = max(self.waterAmount - 0.05, 0)
                        })
                        
                        Text("\(String(format: "%.2f", waterAmount)) L")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        Button(action: {
                            generatorLight.impactOccurred()
                            self.waterAmount += 0.25
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Color.secondary)
                        }
                        .gesture(LongPressGesture(minimumDuration: 0.5).onEnded {_ in
                            generatorLight.impactOccurred()
                            self.waterAmount += 0.05
                        })
                    }
                    
                    
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
                    Spacer()
                    let gridLayout = [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ]
                    
                    VStack {
                        LazyVGrid(columns: gridLayout, spacing: 10) {
                            WaterSizeButton(iconName: "wineglass.fill", waterAmount: 0.1) // 100ml
                            WaterSizeButton(iconName: "cup.and.saucer.fill", waterAmount: 0.25) // 250ml
                            WaterSizeButton(iconName: "mug.fill", waterAmount: 0.4) // 400ml
                            WaterSizeButton(iconName: "mug.fill", waterAmount: 0.5) // 500ml
                            WaterSizeButton(iconName: "waterbottle.fill", waterAmount: 1) // 1L
                            WaterSizeButton(iconName: "waterbottle.fill", waterAmount: 2) // 2L
                        }
                        .padding(.top, 30.0)
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
