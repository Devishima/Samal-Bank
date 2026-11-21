import SwiftUI
import AVFoundation

struct QRScannerView: View {
    @EnvironmentObject var store: BankStore
    @Environment(\.presentationMode) var presentationMode
    @State private var scannedCode: String?
    @State private var showSheet = false
    var body: some View {
        NavigationView {
            ZStack {
                QRCameraPreview { code in
                    guard scannedCode == nil else { return }
                    scannedCode = code; showSheet = true
                }.ignoresSafeArea()
                VStack {
                    Spacer()
                    Image(systemName: "qrcode.viewfinder").font(.system(size: 200)).foregroundStyle(.white.opacity(0.5))
                    Spacer()
                    Text("Наведите камеру на QR-код").font(.headline).foregroundStyle(.white).padding().background(Color.black.opacity(0.5)).clipShape(RoundedRectangle(cornerRadius: 12)).padding(.bottom, 40)
                }
            }
            .background(Color.black).navigationTitle("QR оплата").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Закрыть") { presentationMode.wrappedValue.dismiss() } } }
            .sheet(isPresented: $showSheet) { if let code = scannedCode { QRPaymentSheet(merchantCode: code) { presentationMode.wrappedValue.dismiss() } } }
        }
    }
}

struct QRCameraPreview: UIViewControllerRepresentable {
    var onCode: (String) -> Void
    func makeUIViewController(context: Context) -> ScannerVC { let vc = ScannerVC(); vc.onCode = onCode; return vc }
    func updateUIViewController(_ vc: ScannerVC, context: Context) {}
}

final class ScannerVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var onCode: ((String) -> Void)?
    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    override func viewDidLoad() {
        super.viewDidLoad(); view.backgroundColor = .black
        guard let device = AVCaptureDevice.default(for: .video), let input = try? AVCaptureDeviceInput(device: device), session.canAddInput(input) else { return }
        session.addInput(input)
        let output = AVCaptureMetadataOutput()
        if session.canAddOutput(output) { session.addOutput(output); output.setMetadataObjectsDelegate(self, queue: .main); output.metadataObjectTypes = [.qr] }
        let layer = AVCaptureVideoPreviewLayer(session: session); layer.frame = view.bounds; layer.videoGravity = .resizeAspectFill; view.layer.addSublayer(layer); self.previewLayer = layer
        DispatchQueue.global(qos: .userInitiated).async { self.session.startRunning() }
    }
    override func viewDidLayoutSubviews() { super.viewDidLayoutSubviews(); previewLayer?.frame = view.bounds }
    override func viewWillDisappear(_ animated: Bool) { super.viewWillDisappear(animated); session.stopRunning() }
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let obj = metadataObjects.first as? AVMetadataMachineReadableCodeObject, let value = obj.stringValue else { return }
        session.stopRunning(); onCode?(value)
    }
}
