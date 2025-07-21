import SwiftUI

struct JournalEntry: Codable, Identifiable {
    let id: UUID
    let text: String
    let date: Date
}

struct JournalView: View {
    @State private var journalText: String = ""
    @State private var entries: [JournalEntry] = []

    private let fileURL: URL = {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("journal_entries.json")
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("My Journal")
                .font(.custom("Avenir Next", size: 32).weight(.bold))
                .foregroundColor(.white)
                .padding(.top)

            TextEditor(text: $journalText)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.purple.opacity(0.4), lineWidth: 1)
                        )
                )
                .frame(height: 180)
                .foregroundColor(.white)
                .font(.custom("Avenir Next", size: 16))

            Button("Save Entry") {
                saveEntry()
            }
            .font(.custom("Avenir Next", size: 18).weight(.semibold))
            .padding()
            .frame(maxWidth: .infinity)
            .background(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
            .foregroundColor(.white)
            .cornerRadius(16)

            if entries.isEmpty {
                Text("No entries yet.")
                    .foregroundColor(.white.opacity(0.6))
                    .font(.custom("Avenir Next", size: 14))
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(entries.reversed()) { entry in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(formattedDate(entry.date))
                                    .font(.custom("Avenir Next", size: 12))
                                    .foregroundColor(.white.opacity(0.6))

                                Text(entry.text)
                                    .font(.custom("Avenir Next", size: 16))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.purple.opacity(0.2), .blue.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(16)
                        }
                    }
                }
            }

            Spacer()
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            loadEntries()
        }
    }

    private func saveEntry() {
        let trimmedText = journalText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        let newEntry = JournalEntry(id: UUID(), text: trimmedText, date: Date())
        entries.append(newEntry)
        journalText = ""

        do {
            let data = try JSONEncoder().encode(entries)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save journal entry:", error)
        }
    }

    private func loadEntries() {
        do {
            let data = try Data(contentsOf: fileURL)
            entries = try JSONDecoder().decode([JournalEntry].self, from: data)
        } catch {
            entries = []
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

