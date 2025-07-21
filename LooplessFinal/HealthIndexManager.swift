//
//  HealthIndexManager.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/18/25.
//

import Foundation
import Vision
import AVFoundation
import SwiftUI

class HealthIndexManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var healthIndex: Int = 0
    @Published var isExercising = false

    public var captureSession = AVCaptureSession()
    private var request = VNDetectHumanBodyPoseRequest()
    private var lastSquatState = false

    override init() {
        super.init()
        setupCamera()
    }

    private func setupCamera() {
        // ✅ Use front camera
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }
        guard let input = try? AVCaptureDeviceInput(device: device) else { return }

        captureSession.beginConfiguration()

        for oldInput in captureSession.inputs {
            captureSession.removeInput(oldInput)
        }

        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }

        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))

        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }

        captureSession.commitConfiguration()
        captureSession.startRunning()
    }


    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        do {
            try handler.perform([request])
            if let observation = request.results?.first {
                processObservation(observation)
            }
        } catch {
            print("Pose detection failed: \(error)")
        }
    }

    private func processObservation(_ observation: VNHumanBodyPoseObservation) {
        guard let hip = try? observation.recognizedPoint(.rightHip),
              let knee = try? observation.recognizedPoint(.rightKnee),
              let ankle = try? observation.recognizedPoint(.rightAnkle) else { return }

        guard hip.confidence > 0.6, knee.confidence > 0.6, ankle.confidence > 0.6 else { return }

        let verticalDistance = hip.location.y - knee.location.y

        DispatchQueue.main.async {
            if verticalDistance < 0.1 {
                // User is squatting
                if !self.lastSquatState {
                    self.lastSquatState = true
                    self.healthIndex += 1
                    self.isExercising = true
                }
            } else {
                self.lastSquatState = false
                self.isExercising = false
            }
        }
    }
}

