import AVFoundation
import SwiftUI
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
    var frameProcessingTimer: Timer?
    let frameProcessingQueue = DispatchQueue(label: "FrameProcessingQueue")
    
    @Published var itemCategory: String?
    @Published var itemCalories: String?
    @Published var itemSugar: String?
    @Published var itemDescription: String?
    @Published var shouldDismiss: Bool = false
    @Published var shouldNavigate: Bool = false
    
    @Published var isNavigatingAwayFromCameraView: Bool = false

    

    override init() {
        guard let model = try? VNCoreMLModel(for: FoodFlare_Classification_1().model) else {
            fatalError("Unable to load model")
        }
        self.model = model
        super.init()
        self.startFrameProcessingTimer()
    }

    func startFrameProcessingTimer() {
        self.frameProcessingTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.frameProcessingQueue.async { self.processLastFrame() }
        }
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
                    if self.session.canAddOutput(output) {
                        self.session.addOutput(output)
                    } else {
                        print("Couldn't add video output")
                        return
                    }
                    
                    do {
                        self.session.startRunning()
                    } catch {
                        print("Couldn't start the AVCaptureSession: \(error)")
                        return
                    }
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
                    //gentleFeedbackGenerator.impactOccurred()
                        
                    DispatchQueue.main.async {
                        self.shouldDismiss = true
                        self.detectedItem = firstResult.identifier
                        self.shouldShowDetectedItemSheet = true
                    }
                } else {
                    print("Nothing detected with sufficient confidence.")
                    //strongFeedbackGenerator.impactOccurred()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        //strongFeedbackGenerator.impactOccurred()
                    }
                }
            } else {
                print("No results from VNCoreMLRequest.")
                //strongFeedbackGenerator.impactOccurred()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    //strongFeedbackGenerator.impactOccurred()
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
        NavigationView(content: {
            ZStack {
                // Camera Preview
                GeometryReader { geometry in
                    CameraPreview(session: controller.session)
                        .onAppear(perform: {
                            controller.startSession()
                        })
                        .onDisappear(perform: {
                            controller.session.stopRunning()
                        })
                }
                .ignoresSafeArea(edges: .top)
                
                // Overlay Views
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        
                        if let detectedItem = controller.detectedItem {
                            NavigationLink(
                                destination: HistoryItemView(
                                    detectedItemName: detectedItem,
                                    date: Date(),
                                    shouldShowDetectedItemSheet: $controller.shouldShowDetectedItemSheet,
                                    isNewDetection: .constant(true)
                                )
                                .onAppear(perform: { controller.isNavigatingAwayFromCameraView = true })
                                .onDisappear(perform: { controller.isNavigatingAwayFromCameraView = false })
                            ) {
                                Text(detectedItem)
                                    .font(.system(size: 20, weight: .regular, design: .default))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(17.0)
                                    .frame(maxWidth: .infinity)
                            }
                            .background(Color.clear)
                        } else {
                            Text("No item detected")
                                .font(.system(size: 20, weight: .regular, design: .default))
                                .foregroundColor(Color.white)
                                .padding()
                                .background(Color.secondary)
                                .cornerRadius(17.0)
                                .frame(maxWidth: .infinity)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.clear)
                }
                .buttonStyle(.plain)
                .labelStyle(.iconOnly)
                .padding()
                .padding(.bottom, 60.0)
            }
            .sheet(isPresented: .constant(!controller.isNavigatingAwayFromCameraView)) {
                SheetContentView()
                    .presentationDetents([.height(60.0), .medium, .large])
                    .presentationDragIndicator(.visible)
                    .interactiveDismissDisabled()
                    .presentationBackgroundInteraction(
                        .enabled(upThrough: .large)
                    )
            }
        })
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
