//
//  CameraView.swift
//  FoodFlare App
//
//  Created by Jan Pink on 13.06.23.
//

import AVFoundation
import SwiftUI
import UIKit
import CoreML
import Vision
import CoreData

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        previewLayer.frame = view.bounds

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }
}

final class CameraSessionController: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, ObservableObject {
    @Published var detectedItem: String?
    @Published var shouldShowDetectedItemSheet: Bool = false
    var session: AVCaptureSession = AVCaptureSession()
    var model: VNCoreMLModel
    var lastFrame: CMSampleBuffer?
    let viewContext = PersistenceController.shared.container.viewContext
    
    @Published var itemCategory: String?
    @Published var itemCalories: String?
    @Published var itemSugar: String?
    @Published var itemDescription: String?
    @Published var shouldDismiss: Bool = false
    @Published var shouldNavigate: Bool = false
    
    @Published var showAlert = false  // Add this line

    override init() {
        guard let model = try? VNCoreMLModel(for: FoodFlare_Classification_1().model) else {
            fatalError("Unable to load model")
        }

        self.model = model
    }

    func startSession() {
        if !session.isRunning {
            checkCameraAuthorization { isAuthorized in
                guard isAuthorized else {
                    return
                }
                
                // Define the capture device we want to use
                guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                    print("No camera available - are you on a simulator?")
                    return
                }

                do {
                    // Add the input for the capture session
                    let input = try AVCaptureDeviceInput(device: camera)
                    if self.session.canAddInput(input) {
                        self.session.addInput(input)
                    } else {
                        print("Couldn't add camera input")
                    }
                } catch {
                    print("Couldn't create camera input: \(error)")
                    return
                }

                let output = AVCaptureVideoDataOutput()
                output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
                self.session.addOutput(output)

                self.session.startRunning()
            }
        }
    }

    func checkCameraAuthorization(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completion(granted)
            }
        default:
            completion(false)
        }
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        self.lastFrame = sampleBuffer
    }

    func processLastFrame() {
        // Instantiate the haptic feedback generators
        let gentleFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        let strongFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
            
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(lastFrame!) else {
            print("Could not get image buffer.")
            return
        }

        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let self = self else {
                print("Could not get self reference.")
                return
            }

            if let results = request.results as? [VNClassificationObservation],
               let firstResult = results.first {
                if firstResult.confidence > 0.75 {
                    print("Classification: \(firstResult.identifier), Confidence: \(firstResult.confidence)")
                    // Trigger a light haptic feedback
                    gentleFeedbackGenerator.impactOccurred()
                        
                    DispatchQueue.main.async {
                        self.shouldDismiss = true
                        self.detectedItem = firstResult.identifier
                        self.shouldShowDetectedItemSheet = true // Show the sheet when an item is detected
                    }
                } else {
                    print("Nothing detected with sufficient confidence.")
                    // Trigger multiple heavy haptic feedbacks to indicate a warning
                    strongFeedbackGenerator.impactOccurred()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        strongFeedbackGenerator.impactOccurred()

                        // Show the alert
                        DispatchQueue.main.async {
                            self.showAlert = true
                        }
                    }
                }
            } else {
                print("No results from VNCoreMLRequest.")
                // Trigger multiple heavy haptic feedbacks to indicate a warning
                strongFeedbackGenerator.impactOccurred()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    strongFeedbackGenerator.impactOccurred()

                    // Show the alert
                    DispatchQueue.main.async {
                        self.showAlert = true
                    }
                }
            }
        }

        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
}


struct CameraView: View {
    @StateObject private var controller = CameraSessionController()
    

    var body: some View {
        NavigationView {
            ZStack {
                CameraPreview(session: controller.session)
                    .onAppear(perform: {
                        controller.startSession()
                    })
                    .onDisappear(perform: {
                        controller.session.stopRunning()
                    })
                    .edgesIgnoringSafeArea(.all) // Make CameraPreview take up the whole screen

                VStack {
                    Spacer()
                    HStack {
                        Button(action: {
                            controller.processLastFrame()
                        }) {
                            Text("Snap")
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
                    .padding()
                }
                .alert(isPresented: $controller.showAlert) {
                    Alert(title: Text("Warning"),
                          message: Text("Nothing detected with sufficient confidence."),
                          dismissButton: .default(Text("OK")))
                }
                .sheet(isPresented: $controller.shouldShowDetectedItemSheet) {
                    if let detectedItem = controller.detectedItem {
                        let itemImage = controller.lastFrame
                        let itemCategory = controller.itemCategory
                        let itemCalories = controller.itemCalories
                        let itemSugar = controller.itemSugar
                        let itemDescription = controller.itemDescription
                        HistoryItemView(detectedItemName: detectedItem, date: Date(), shouldShowDetectedItemSheet: $controller.shouldShowDetectedItemSheet, isNewDetection: .constant(true))

                    }
                }
            }
            .onReceive(controller.$shouldDismiss, perform: { shouldDismiss in
                if shouldDismiss {
                    controller.shouldDismiss = false
                    controller.shouldNavigate = false // Reset the navigation flag
                }
            })
        }
        .navigationTitle("Add Food")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
