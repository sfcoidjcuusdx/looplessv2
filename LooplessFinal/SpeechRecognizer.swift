import SwiftUI
import Speech
import AVFoundation

class SpeechRecognizer: ObservableObject {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    @Published var transcript: String = ""

    func startTranscribing() throws {
        recognitionTask?.cancel()
        recognitionTask = nil

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create recognition request")
        }
        recognitionRequest.shouldReportPartialResults = true

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.transcript = result.bestTranscription.formattedString
                }
            }

            if error != nil || (result?.isFinal ?? false) {
                self.stopTranscribing()
            }
        }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
    }

    func stopTranscribing() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask = nil
    }
}

struct VoiceJournalEntry: Identifiable, Codable {
    let id = UUID()
    let text: String
    let date: Date
}

struct VoiceJournalView: View {
    @StateObject private var recognizer = SpeechRecognizer()
    @State private var isRecording = false
    @State private var savedEntries: [VoiceJournalEntry] = []
    @State private var showAnalysisPopup = false
    @State private var aiAnalysis = "Analyzing your voice journal..."

    private let entriesKey = "SavedVoiceJournalEntries"

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 20) {
                Text("Voice Journal")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)

                ScrollView {
                    VStack(spacing: 16) {
                        Group {
                            Text(recognizer.transcript.isEmpty ? "Your speech will appear here..." : recognizer.transcript)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }

                        ForEach(savedEntries.reversed()) { entry in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(entry.text)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)

                                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                Button(action: {
                    if isRecording {
                        recognizer.stopTranscribing()
                    } else {
                        try? recognizer.startTranscribing()
                    }
                    isRecording.toggle()
                }) {
                    Label(isRecording ? "Stop Recording" : "Start Speaking", systemImage: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .background(isRecording ? Color.red : Color.cyan)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }

                if !isRecording && !recognizer.transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Button(action: saveEntry) {
                        Label("Save Response", systemImage: "square.and.arrow.down")
                            .font(.body.weight(.medium))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.cyan)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                }

                Spacer()
            }
            .padding(.bottom)
            .onAppear(perform: loadEntries)

            // Chat icon in bottom right
            Button(action: {
                showAnalysisPopup = true
                aiAnalysis = "Analyzing your voice journal..."
                Task {
                    await GeminiAPIManager.analyzeVoiceJournalEntries(savedEntries) { response in
                        aiAnalysis = response
                    }
                }
            }) {
                Image(systemName: "message.circle.fill")
                    .resizable()
                    .frame(width: 44, height: 44)
                    .foregroundColor(.blue)
                    .padding()
            }
        }

        // AI popup overlay
        .overlay(
            Group {
                if showAnalysisPopup {
                    ZStack {
                        Color.black.opacity(0.4).ignoresSafeArea()
                        VStack(alignment: .leading, spacing: 16) {
                            Text("AI Analysis")
                                .font(.title2).bold()

                            ScrollView {
                                Text(aiAnalysis)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .padding()
                            }

                            Button("Close") {
                                showAnalysisPopup = false
                            }
                            .font(.body.bold())
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .padding()
                    }
                }
            }
        )
    }

    private func saveEntry() {
        let trimmed = recognizer.transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let newEntry = VoiceJournalEntry(text: trimmed, date: Date())
        savedEntries.append(newEntry)

        if let encoded = try? JSONEncoder().encode(savedEntries) {
            UserDefaults.standard.set(encoded, forKey: entriesKey)
        }

        recognizer.transcript = ""
    }

    private func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: entriesKey),
           let decoded = try? JSONDecoder().decode([VoiceJournalEntry].self, from: data) {
            savedEntries = decoded
        }
    }
}

