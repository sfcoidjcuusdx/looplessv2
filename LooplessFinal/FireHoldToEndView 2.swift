//
//  FireHoldToEndView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/17/25.
//

import SwiftUI
import Lottie
import CoreHaptics

struct FireHoldToEndView: View {
    var onComplete: () -> Void
    var onCancel: () -> Void

    @State private var holdTime: Double = 0
    @State private var timer: Timer?
    @State private var opacity: Double = 1.0
    @State private var isHolding = false
    @State private var engine: CHHapticEngine?

    let totalHoldDuration: Double = 10.0

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                VStack(spacing: 12) {
                    Text("Are You Sure?")
                        .font(.title.bold())
                        .foregroundColor(.primary)

                    Text("This session was created to help you grow.\nAre you really ready to stop now?")
                        .multilineTextAlignment(.center)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 24)
                }

                VStack(spacing: 8) {
                    LottieView(animationName: "Fire", loopMode: .loop)
                        .frame(width: 160, height: 160)
                        .opacity(opacity)
                        .scaleEffect(isHolding ? 1.05 : 1.0)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    if !isHolding {
                                        isHolding = true
                                        startHaptic()
                                        startTimer()
                                    }
                                }
                                .onEnded { _ in
                                    stopTimer()
                                    onCancel()
                                }
                        )

                    Text("Hold to extinguish the fire")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.secondary)

                    Text("\(Int(max(totalHoldDuration - holdTime, 0)))s remaining")
                        .font(.title3.weight(.heavy))
                        .foregroundColor(.primary)
                }

                VStack(spacing: 12) {
                    Text("Letting go now means giving in to old habits.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    Button(action: {
                        stopTimer()
                        onCancel()
                    }) {
                        Text("Nevermind, I’ll stay strong")
                            .font(.body.weight(.bold))
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 32)
                }
            }
            .padding(.vertical, 40)
        }
        .onAppear {
            prepareHaptics()
        }
        .onDisappear {
            stopTimer()
        }
    }

    func startTimer() {
        holdTime = 0
        opacity = 1.0
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { t in
            holdTime += 0.1
            opacity = max(0, 1.0 - (holdTime / totalHoldDuration))
            playHapticStep()

            if holdTime >= totalHoldDuration {
                t.invalidate()
                stopHaptic()
                onComplete()
            }
        }
    }

    func stopTimer() {
        isHolding = false
        timer?.invalidate()
        stopHaptic()
        opacity = 1.0
    }

    func prepareHaptics() {
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Haptics engine not available: \(error.localizedDescription)")
        }
    }

    func startHaptic() {
        try? engine?.start()
    }

    func stopHaptic() {
        engine?.stop(completionHandler: nil)
    }

    func playHapticStep() {
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(min(1.0, holdTime / totalHoldDuration)))
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: 0.1)

        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play haptic: \(error.localizedDescription)")
        }
    }
}

