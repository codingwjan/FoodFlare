//
//  FoodDetails.swift
//  FoodFlare App
//
//  Created by Jan Pink on 13.06.23.
//

import SwiftUI

struct FoodDetails: View {
    let text: String
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Spacer()
                Text("Details")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Button(action: {
                    print("dissmiss")
                }, label: {
                    Image(systemName: "xmark")
                })
            }
            VStack(alignment: .leading) {
                Text(text)
                    .padding(.top)
            }
            Spacer()
        }
        .padding()
    }
}

struct FoodDetails_Previews: PreviewProvider {
    static var previews: some View {
        FoodDetails(text: "aliquip culpa officia pariatur dolor qui nostrud duis culpa cillum ex adipisicing qui cillum anim do voluptate mollit labore nulla consequat veniam nulla qui ipsum cillum cillum officia fugiat amet culpa dolor nulla eiusmod labore qui veniam magna ea aute excepteur ut quis do mollit pariatur Lorem aliqua ut ipsum")
    }
}
