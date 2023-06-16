//
//  CreateButton.swift
//  FoodFlare App
//
//  Created by Jan Pink on 13.06.23.
//

import SwiftUI
import UIKit

struct CreateButton: View {
    // Create a medium impact feedback generator
    private let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        NavigationLink(destination: CameraView()) {
            Spacer()
            Text("New Scan")
                .font(.system(size: 20, weight: .regular, design: .default))
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.vertical, 15.0)
        .background(Color.blue)
        .cornerRadius(17.0)
        .frame(maxWidth: .infinity)
        .simultaneousGesture(TapGesture().onEnded {
            self.impactGenerator.impactOccurred()
        })
    }
}


struct CreateButton_Previews: PreviewProvider {
    static var previews: some View {
        CreateButton()
    }
}
