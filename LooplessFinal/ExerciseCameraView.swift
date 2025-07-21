import SwiftUI
import AVFoundation

struct ExerciseCameraView: UIViewRepresentable {
    @ObservedObject var manager: HealthIndexManager

    func makeUIView(context: Context) -> UIView {
        let view = UIView()

        let previewLayer = AVCaptureVideoPreviewLayer(session: manager.captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = UIScreen.main.bounds

        // ✅ Fix mirror for front camera
        if let connection = previewLayer.connection, connection.isVideoMirroringSupported {
            connection.automaticallyAdjustsVideoMirroring = false
            connection.isVideoMirrored = true
        }

        view.layer.addSublayer(previewLayer)
        return view
    }


    func updateUIView(_ uiView: UIView, context: Context) {}
}

