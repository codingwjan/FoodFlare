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
    
    @Published var showAlert = false

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
                
                guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                    print("No camera available - are you on a simulator?")
                    return
                }

                do {
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
        DispatchQueue.main.async { [weak self] in
            self?.lastFrame = sampleBuffer
        }
    }

    func processLastFrame() {
        let gentleFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        let strongFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
            
        guard let lastFrame = lastFrame, let pixelBuffer = CMSampleBufferGetImageBuffer(lastFrame) else {
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
                    gentleFeedbackGenerator.impactOccurred()
                        
                    DispatchQueue.main.async {
                        self.shouldDismiss = true
                        self.detectedItem = firstResult.identifier
                        self.shouldShowDetectedItemSheet = true
                    }
                } else {
                    print("Nothing detected with sufficient confidence.")
                    strongFeedbackGenerator.impactOccurred()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        strongFeedbackGenerator.impactOccurred()

                        DispatchQueue.main.async {
                            self.showAlert = true
                        }
                    }
                }
            } else {
                print("No results from VNCoreMLRequest.")
                strongFeedbackGenerator.impactOccurred()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    strongFeedbackGenerator.impactOccurred()

                    DispatchQueue.main.async {
                        self.showAlert = true
                    }
                }
            }
        }

        do {
            try VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        } catch {
            print("Error performing image request: \(error)")
        }
    }
}

struct CameraView: View {
    @StateObject private var controller = CameraSessionController()

    var body: some View {
        GeometryReader { geometry in
            CameraPreview(session: controller.session)
                .onAppear(perform: {
                    controller.startSession()
                })
                .onDisappear(perform: {
                    controller.session.stopRunning()
                })
                .overlay(alignment: .bottom) {
                    buttonsView()
                        .frame(height: geometry.size.height * 0.3)
                }
                .background(Color.black)
        }
        .ignoresSafeArea(edges: .top)
    }
    
    private func buttonsView() -> some View {
        HStack(spacing: 60) {
            Spacer()
            Button {
                controller.processLastFrame()
            } label: {
                ZStack {
                    Circle()
                        .strokeBorder(Color.white, lineWidth: 3)
                        .frame(width: 62, height: 62)
                    Circle()
                        .fill(Color.white)
                        .frame(width: 50, height: 50)
                }
            }
            Spacer()
        }
        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
        .padding()
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
        .sheet(isPresented: .constant(true)) {
                            SheetContentView()
                                .presentationDetents([.height(60.0), .medium, .large])
                                .presentationDragIndicator(.visible)
                                .interactiveDismissDisabled()
                                .presentationBackgroundInteraction(
                                    .enabled(upThrough: .large)
                                )
                        }
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
