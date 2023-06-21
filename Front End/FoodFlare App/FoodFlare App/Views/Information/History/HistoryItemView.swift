//
//  HistoryItemView.swift
//  FoodFlare
//
//  Created by Jan Pink on 17.06.23.
//

import SwiftUI
import CoreData

struct HistoryItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: FoodItem.entity(), sortDescriptors: []) private var foodItems: FetchedResults<FoodItem>
    
    let detectedItemName: String
    let date: Date
    
    @Binding var shouldShowDetectedItemSheet: Bool
    @State var showDetailsSheet: Bool = false
    
    let confirmationGenerator = UINotificationFeedbackGenerator()
    
    @Binding var isNewDetection: Bool
    @State private var foodAmount: Int16 = 100

    
    func imageExists(_ imageName: String) -> Bool {
            return UIImage(named: imageName) != nil
        }
    
    var body: some View {
        let detectedItem = foodItems.first(where: { $0.foodName == detectedItemName })
        let formattedDetectedItemName = detectedItemName.replacingOccurrences(of: "_", with: " ").capitalized

        let calories = detectedItem?.foodCalories ?? 0
        
        let walkingDistance = (Double(calories) / 300) * 5
        let runningDistance = (Double(calories) / 800) * 10
        let cyclingDistance = (Double(calories) / 600) * 15
        let weightLiftingTime = (Double(calories) / 300) * 90
        let squashTime = (Double(calories) / 400) * 30
        
        let formattedFoodCategory = detectedItem?.foodCategory?.replacingOccurrences(of: "_", with: " ").capitalized ?? "default"
        
        
        NavigationView(content: {
            ScrollView {
                VStack {
                    ZStack {
                        GeometryReader { geometry in
                            Image(imageExists(detectedItemName) ? detectedItemName : "default")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: 400)
                                .clipped()
                        }
                        .edgesIgnoringSafeArea(.top)
                        
                        
                        VStack {
                            Spacer()
                            VStack(alignment: .leading) {
                                Text(String(formattedDetectedItemName))
                                    .font(.largeTitle)
                                    .textInputAutocapitalization(.characters)
                                    .fontWeight(.heavy)
                                    .foregroundColor(Color.white)
                                    .padding(.leading)
                                
                                HStack {
                                    Text(formattedFoodCategory)
                                        .font(.title3)
                                        .fontWeight(.regular)
                                        .foregroundColor(Color.white)
                                        .textInputAutocapitalization(.words)
                                    
                                    Text("•")
                                        .font(.title3)
                                        .foregroundColor(Color.white)
                                    
                                    Text("\(detectedItem?.foodCalories ?? 0) cal")
                                        .font(.title3)
                                        .fontWeight(.regular)
                                        .foregroundColor(Color.white)
                                    
                                    Text("•")
                                        .font(.title3)
                                        .foregroundColor(Color.white)
                                    
                                    Text("\(detectedItem?.foodSugar ?? 0) g")
                                        .font(.title3)
                                        .fontWeight(.regular)
                                        .foregroundColor(Color.white)
                                    
                                    Spacer()
                                }
                                .padding([.bottom, .leading])
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    }
                }
                .frame(height: 400)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Spacer()
                        ItemBoxView(icon: "figure.walk", text: String(format: "%.1f KM", walkingDistance))
                        ItemBoxView(icon: "figure.run", text: String(format: "%.1f KM", runningDistance))
                        ItemBoxView(icon: "figure.outdoor.cycle", text: String(format: "%.1f KM", cyclingDistance))
                        ItemBoxView(icon: "figure.strengthtraining.traditional", text: String(format: "%.1f MIN", weightLiftingTime))
                        ItemBoxView(icon: "figure.squash", text: String(format: "%.1f MIN", squashTime))
                        Spacer()
                    }
                }
                
                Divider()
                VStack(alignment: .leading) {
                    if(detectedItem?.foodAmountMatters ?? false == true) {
                        Stepper(value: $foodAmount, in: 25...2000, step: 25) {
                            Text("Food Amount: \(foodAmount)g")
                        }
                        .onChange(of: foodAmount) { _ in
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                        }
                        
                        Button(action: {
                            let newStatistics = Statistics(context: viewContext)
                            newStatistics.date = Date()
                            
                            if let detectedItem = foodItems.first(where: { $0.foodName == detectedItemName }) {
                                newStatistics.foodName = detectedItem.foodName
                                newStatistics.foodCategory = detectedItem.foodCategory
                                newStatistics.foodCalories = Int16((Double(detectedItem.foodCalories) / 100.0) * Double(foodAmount))
                                newStatistics.foodSugar = Int16((Double(detectedItem.foodSugar) / 100.0) * Double(foodAmount))
                                newStatistics.foodCategoryColor = detectedItem.foodCategoryColor
                            }
                            
                            do {
                                try viewContext.save()
                                confirmationGenerator.notificationOccurred(.success)
                                print("Saved new statistics item: \(newStatistics)")
                                print("foodamount was \(Int16(foodAmount))")
                                print("calotries were \(newStatistics.foodCalories)")
                                
                                
                            } catch {
                                let nsError = error as NSError
                                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                            }
                        }) {
                            Text("Let's Eat")
                                .font(.system(size: 20, weight: .regular, design: .default))
                                .foregroundColor(.white)
                                .fontWeight(.regular)
                                .padding(.vertical, 15.0)
                                .padding(.horizontal, 20.0)
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .accentColor(.white)
                                .cornerRadius(17.0)
                        }
                        .padding(.top)
                    } else {
                        Button(action: {
                            let newStatistics = Statistics(context: viewContext)
                            newStatistics.date = Date()
                            
                            if let detectedItem = foodItems.first(where: { $0.foodName == detectedItemName }) {
                                newStatistics.foodName = detectedItem.foodName
                                newStatistics.foodCategory = detectedItem.foodCategory
                                newStatistics.foodCalories = detectedItem.foodCalories
                                newStatistics.foodSugar = detectedItem.foodSugar
                                newStatistics.foodCategoryColor = detectedItem.foodCategoryColor
                            }
                            
                            do {
                                try viewContext.save()
                                confirmationGenerator.notificationOccurred(.success)
                                print("Saved new statistics item: \(newStatistics)")
                                
                                
                            } catch {
                                let nsError = error as NSError
                                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                            }
                        }) {
                            Text("Let's Eat")
                                .font(.system(size: 20, weight: .regular, design: .default))
                                .foregroundColor(.white)
                                .fontWeight(.regular)
                                .padding(.vertical, 15.0)
                                .padding(.horizontal, 20.0)
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .accentColor(.white)
                                .cornerRadius(17.0)
                        }
                    }
                    Button(action: {
                        // Toggle favorite status and save context
                        detectedItem?.isFavourite.toggle()
                        do {
                            try viewContext.save()
                            confirmationGenerator.notificationOccurred(.success)
                        } catch {
                            let nsError = error as NSError
                            print("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                    }) {
                        Text(detectedItem?.isFavourite == true ? "Favorited" : "Add to Favorites")
                            .font(.system(size: 20, weight: .regular, design: .default))
                            .fontWeight(.regular)
                            .padding(.vertical, 15.0)
                            .padding(.horizontal, 20.0)
                            .frame(maxWidth: .infinity)
                            .background(detectedItem?.isFavourite == true ? Color.orange : Color.gray)
                            .accentColor(.white)
                            .cornerRadius(17.0)
                    }
                    
                    Text("Details")
                        .font(.title)
                        .fontWeight(.bold)
                        .onTapGesture {
                            showDetailsSheet = true
                        }
                    Text((detectedItem?.foodDescription ?? "Description unavailable").prefix(words: 15) + "…")
                        .multilineTextAlignment(.leading)
                        .onTapGesture {
                            showDetailsSheet = true
                        }
                    Text("Read more")
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                    
                        .sheet(isPresented: $showDetailsSheet) {
                            // Replace "DetailsSheetView" with your custom sheet view
                            FoodDetails(text: detectedItem?.foodDescription ?? "", showDetailsSheet: $showDetailsSheet)
                        }
                        .onTapGesture {
                            showDetailsSheet = true
                        }
                }
                .padding()
            }
            .ignoresSafeArea()
        })
        .frame(maxWidth: .infinity) // Make VStack take up full width
                .onAppear(perform: {
                    if (isNewDetection == true) {
                        saveHistory()
                    }
                })
    }
}

extension String {
    func prefix(words: Int) -> String {
        let wordsArray = self.split(separator: " ")
        let prefixWords = wordsArray.prefix(words)
        return prefixWords.joined(separator: " ")
    }
}

private extension HistoryItemView {
    func saveHistory() {
        let newHistoryItem = History(context: viewContext)
        newHistoryItem.foodName = detectedItemName
        newHistoryItem.date = Date()

        // Here we fetch the detected item from CoreData
        if let detectedItem = foodItems.first(where: { $0.foodName == detectedItemName }) {
            newHistoryItem.foodCategory = detectedItem.foodCategory
        }

        do {
            try viewContext.save()
            print("Saved new history item: \(newHistoryItem)")
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

                       

struct HistoryItemView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryItemView(detectedItemName: "carrot", date: Date(), shouldShowDetectedItemSheet: .constant(false), isNewDetection: .constant(false))
    }
}
