import SwiftUI
import CoreData

struct DetectedItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: FoodItem.entity(), sortDescriptors: []) private var foodItems: FetchedResults<FoodItem>
    
    let detectedItemName: String
    @Binding var shouldShowDetectedItemSheet: Bool
    @State var showDetailsSheet: Bool = false

    var body: some View {
        // Here we fetch the detected item from CoreData
        let detectedItem = foodItems.first(where: { $0.foodName == detectedItemName })
        
        let calories = detectedItem?.foodCalories ?? 0

        let walkingDistance = (Double(calories) / 300) * 5
        let runningDistance = (Double(calories) / 800) * 10
        let cyclingDistance = (Double(calories) / 600) * 15
        let weightLiftingTime = (Double(calories) / 300) * 90
        let squashTime = (Double(calories) / 400) * 30

        
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    VStack {
                        ZStack {
                            Image(detectedItem?.foodName ?? "default")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 400)
                                .clipped()
                                .edgesIgnoringSafeArea(.top)
                            
                            
                            VStack {
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        shouldShowDetectedItemSheet = false
                                    }, label: {
                                        Image(systemName: "xmark")
                                            .foregroundColor(Color.white)
                                            .padding(8.0)
                                            .background(Color.gray)
                                            .clipShape(Circle())
                                    })
                                    .padding()
                                }
                                Spacer()
                                VStack {
                                    HStack {
                                        Text(detectedItem?.foodName ?? "")
                                            .textInputAutocapitalization(.words)
                                            .font(.largeTitle)
                                            .fontWeight(.heavy)
                                            .foregroundColor(Color.white)
                                            .padding(.leading)

                                        Spacer()
                                    }
                                    ScrollView(.horizontal, showsIndicators: false){
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
                            print("button pressed")
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
                        Text((detectedItem?.foodDescription ?? "Description unavalible").prefix(words: 15) + "…")
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
            }
        }
        .ignoresSafeArea(edges: .top)
        .onAppear(perform: saveHistory)
    }
}

private extension DetectedItemView {
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

extension String {
    func prefix(words: Int) -> String {
        let array = self.components(separatedBy: " ")
        if array.count > words {
            let prefixArray = array.prefix(words)
            return prefixArray.joined(separator: " ")
        } else {
            return self
        }
    }
}



struct DetectedItemView_Previews: PreviewProvider {
    @State static var shouldShow = true

    static var previews: some View {
        DetectedItemView(detectedItemName: "white", shouldShowDetectedItemSheet: $shouldShow)
    }
}
