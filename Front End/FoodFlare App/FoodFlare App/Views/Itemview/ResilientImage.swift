//
//  ResilientImage.swift
//  FoodFlare
//
//  Created by Jan Pink on 16.06.23.
//

import SwiftUI

struct ResilientImage: View {
    let imageName: String
    let defaultImageName: String = "default"

    var body: some View {
        Group {
            if let _ = UIImage(named: imageName) {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Image(defaultImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
    }
}

struct ResilientImage_Previews: PreviewProvider {
    @State static var shouldShow = true

    static var previews: some View {
        ResilientImage(imageName: "default")
    }
}
