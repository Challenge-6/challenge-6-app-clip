//
//  QrCodeScanner.swift
//  challenge6
//
//  Created by Lucas on 04/11/26.
//

import SwiftUI
import AVFoundation

struct QRScannerView: UIViewControllerRepresentable {
    var onScan: (String) -> Void

    func makeUIViewController(context: Context) -> ScannerController {
        let vc = ScannerController()
        vc.onScan = onScan
        return vc
    }
    func updateUIViewController(_ uiViewController: ScannerController, context: Context) {}
}

final class ScannerController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var onScan: ((String) -> Void)?
    private let session = AVCaptureSession()
    private let preview = AVCaptureVideoPreviewLayer()
    private var didScan = false

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else { return }
        session.addInput(input)

        let output = AVCaptureMetadataOutput()
        guard session.canAddOutput(output) else { return }
        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: .main)
        output.metadataObjectTypes = [.qr]

        preview.session = session
        preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(preview)

        DispatchQueue.global(qos: .userInitiated).async { self.session.startRunning() }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preview.frame = view.bounds
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard !didScan,
              let obj = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let text = obj.stringValue else { return }
        didScan = true
        session.stopRunning()
        onScan?(text)
    }
}

func parseHost(_ text: String) -> (host: String, port: UInt16)? {
    let parts = text.split(separator: ":")
    guard parts.count == 2, let port = UInt16(parts[1]) else { return nil }
    return (String(parts[0]), port)
}
