import SwiftUI

struct JournalEntry: Codable, Identifiable {
    let id: UUID
    let text: String
    let date: Date
}

struct JournalView: View {
    @State private var journalText: String = ""
    @State private var entries: [JournalEntry] = []

    private var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("journal_entries.json")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("My Journal")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)

            CustomTextEditor(text: $journalText)
                .frame(height: 160)

            Button("Save Entry") {
                saveEntry()
            }
            .buttonStyle(.borderedProminent)

            if entries.isEmpty {
                Text("No entries yet.")
                    .foregroundColor(.secondary)
                    .font(.footnote)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(entries.reversed()) { entry in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(formattedDate(entry.date))
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                Text(entry.text)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.secondarySystemGroupedBackground))
                            )
                        }
                    }
                }
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemGroupedBackground))
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
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("❌ Failed to save journal entry:", error.localizedDescription)
        }
    }

    private func loadEntries() {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoded = try JSONDecoder().decode([JournalEntry].self, from: data)
            entries = decoded
        } catch {
            print("ℹ️ No journal file yet or failed to decode: \(error.localizedDescription)")
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

// MARK: - CustomTextEditor (Embedded in same file)

struct CustomTextEditor: UIViewRepresentable {
    @Binding var text: String

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CustomTextEditor

        init(_ parent: CustomTextEditor) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText string: String) -> Bool {
            if string == "\n" {
                textView.resignFirstResponder() // Dismiss keyboard on return
                return false
            }
            return true
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.backgroundColor = UIColor.systemBackground
        textView.layer.cornerRadius = 12
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.gray.withAlphaComponent(0.4).cgColor
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 6, bottom: 8, right: 6)
        textView.returnKeyType = .done
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }
}

