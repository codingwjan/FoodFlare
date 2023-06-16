//
//  BottomSheetView.swift
//  FoodFlare App
//
//  Created by Jan Pink on 13.06.23.
//

import SwiftUI

struct BottomSheetView: View {
    @Binding var isPresented: Bool
    @GestureState private var dragState = DragState.inactive

    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 40, height: 8)
                    .cornerRadius(4)
                    .opacity(0.1)
                    .padding(.top, 8)
                
            }
            HStack {
                
                Text("Title")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                Spacer()
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                }
                .padding(.trailing)
                
            }
        }
            .background(Color.white)
            .cornerRadius(10)
            .offset(y: self.dragState.translation.height)
            .gesture(
                DragGesture()
                    .updating($dragState) { drag, state, transaction in
                        state = .dragging(translation: drag.translation)
                    }
                    .onEnded(onDragEnded)
            )
        
    }

    private func onDragEnded(drag: DragGesture.Value) {
        let verticalDirection = drag.predictedEndTranslation.height / drag.translation.height
        let shouldDismiss = verticalDirection > 0
        if shouldDismiss {
            isPresented = false
        }
    }

    enum DragState {
        case inactive
        case dragging(translation: CGSize)

        var translation: CGSize {
            switch self {
            case .inactive:
                return .zero
            case .dragging(let translation):
                return translation
            }
        }
    }
}


struct BottomSheetView_Previews: PreviewProvider {
    static var previews: some View {
        BottomSheetView(isPresented: .constant(true))
    }
}
