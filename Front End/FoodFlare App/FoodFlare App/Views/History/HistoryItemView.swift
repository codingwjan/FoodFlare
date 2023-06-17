//
//  HistoryItemView.swift
//  FoodFlare
//
//  Created by Jan Pink on 17.06.23.
//

import SwiftUI

struct HistoryItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: FoodItem.entity(), sortDescriptors: []) private var foodItems: FetchedResults<FoodItem>
    
    let detectedItemName: String
    let date: Date
    
    @Binding var shouldShowDetectedItemSheet: Bool
    @State var showDetailsSheet: Bool = false
    
    
    var body: some View {
        let detectedItem = foodItems.first(where: { $0.foodName == detectedItemName })
        
        
        let calories = detectedItem?.foodCalories ?? 0
        
        let walkingDistance = (Double(calories) / 300) * 5
        let runningDistance = (Double(calories) / 800) * 10
        let cyclingDistance = (Double(calories) / 600) * 15
        let weightLiftingTime = (Double(calories) / 300) * 90
        let squashTime = (Double(calories) / 400) * 30
        
        
        NavigationView(content: {
            ScrollView {
                VStack {
                    ZStack {
                        Image(detectedItemName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 400)
                            .clipped()
                            .edgesIgnoringSafeArea(.top)
                        
                        
                        VStack {
                            Spacer()
                            VStack(alignment: .leading) {
                                Text(detectedItemName)
                                    .font(.largeTitle)
                                    .textInputAutocapitalization(.characters)
                                    .fontWeight(.heavy)
                                    .foregroundColor(Color.white)
                                    .padding(.leading)
                                
                                HStack {
                                    Text(detectedItem?.foodCategory ?? "default")
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
                    Button(action: {
                        print("button pressed")
                    }) {
                        Text("Share")
                            .font(.system(size: 20, weight: .regular, design: .default))
                            .fontWeight(.regular)
                            .padding(.vertical, 15.0)
                            .padding(.horizontal, 20.0)
                            .frame(maxWidth: .infinity)
                            .background(Color.secondary)
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
                            FoodDetails(text: detectedItem?.foodDescription ?? "")
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
        .navigationBarTitle("\(date, formatter: DateFormatter.onlyDate)", displayMode: .inline)
    }
}

extension String {
    func prefix(words: Int) -> String {
        let wordsArray = self.split(separator: " ")
        let prefixWords = wordsArray.prefix(words)
        return prefixWords.joined(separator: " ")
    }
}

                       

struct HistoryItemView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryItemView(detectedItemName: "carrot", date: Date(), shouldShowDetectedItemSheet: .constant(false))
    }
}
