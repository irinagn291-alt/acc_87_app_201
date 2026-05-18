import AVFoundation
import SwiftUI
import UIKit

struct AquaISBNScannerView: UIViewControllerRepresentable {
    let onISBN: (String) -> Void
    let onDismiss: () -> Void

    func makeUIViewController(context: Context) -> AquaISBNViewController {
        let vc = AquaISBNViewController()
        vc.onISBN = onISBN
        vc.onDismiss = onDismiss
        return vc
    }

    func updateUIViewController(_ uiViewController: AquaISBNViewController, context: Context) {}
}

final class AquaISBNViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var onISBN: ((String) -> Void)?
    var onDismiss: (() -> Void)?

    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var didEmit = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCancelButton()
        setupHintLabel()
        startCamera()
    }

    private func setupCancelButton() {
        let btn = UIButton(type: .system)
        btn.setTitle("Cancel", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(btn)
        NSLayoutConstraint.activate([
            btn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            btn.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
        ])
    }

    private func setupHintLabel() {
        let lbl = UILabel()
        lbl.text = "Align the ISBN barcode in the frame"
        lbl.textColor = .white
        lbl.font = .systemFont(ofSize: 15, weight: .medium)
        lbl.textAlignment = .center
        lbl.numberOfLines = 2
        lbl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lbl)
        NSLayoutConstraint.activate([
            lbl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            lbl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            lbl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -28),
        ])
    }

    @objc private func cancelTapped() { onDismiss?() }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if session.isRunning { session.stopRunning() }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    private func startCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: configureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] ok in
                DispatchQueue.main.async {
                    if ok { self?.configureSession() } else { self?.onDismiss?() }
                }
            }
        default: onDismiss?()
        }
    }

    private func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .high
        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else { session.commitConfiguration(); onDismiss?(); return }

        session.addInput(input)
        let output = AVCaptureMetadataOutput()
        guard session.canAddOutput(output) else { session.commitConfiguration(); onDismiss?(); return }
        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: .main)
        let supported = output.availableMetadataObjectTypes
        var types: [AVMetadataObject.ObjectType] = []
        if supported.contains(.ean13) { types.append(.ean13) }
        if supported.contains(.ean8) { types.append(.ean8) }
        if supported.contains(.upce) { types.append(.upce) }
        output.metadataObjectTypes = types

        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        preview.frame = view.bounds
        view.layer.insertSublayer(preview, at: 0)
        previewLayer = preview
        session.commitConfiguration()
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in self?.session.startRunning() }
    }

    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard !didEmit else { return }
        for obj in metadataObjects {
            guard
                let readable = obj as? AVMetadataMachineReadableCodeObject,
                let value = readable.stringValue,
                let isbn = AquaISBNNorm.normalize(fromScanned: value)
            else { continue }
            didEmit = true
            session.stopRunning()
            onISBN?(isbn)
            return
        }
    }
}
