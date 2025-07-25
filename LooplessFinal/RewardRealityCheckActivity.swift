import SwiftUI

struct RewardRealityCheckActivity: View {
    @State private var selectedHabit = "Endless scrolling"
    @State private var habitConfirmed = false
    @State private var perceivedRewards: [String] = []
    @State private var actualCosts: [String] = []
    @State private var betterAlternatives: [String] = []
    @State private var currentInput = ""
    @State private var currentCategory: InputCategory = .perceivedRewards
    @State private var showComparison = false
    @State private var showingValidationAlert = false
    @State private var validationMessage = ""
    @State private var isEvaluating = false
    @State private var savedChecks: [RewardCheck] = []
    @State private var showingSavedChecks = false
    @State private var editingExisting = false
    @State private var currentCheckId = UUID()

    enum InputCategory {
        case perceivedRewards, actualCosts, betterAlternatives
    }

    let commonHabits = [
        "Endless scrolling",
        "Checking notifications",
        "Watching random videos",
        "Gaming for hours",
        "Comparing to others online"
    ]

    struct RewardCheck: Identifiable, Codable {
        let id: UUID
        var habit: String
        var perceivedRewards: [String]
        var actualCosts: [String]
        var betterAlternatives: [String]
        var lastEdited: Date
    }

    private var currentCategoryTitle: String {
        switch currentCategory {
        case .perceivedRewards: return "perceived reward"
        case .actualCosts: return "actual cost"
        case .betterAlternatives: return "better alternative"
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Select a Digital Habit")) {
                    Picker("Habit", selection: $selectedHabit) {
                        ForEach(commonHabits, id: \.self) { habit in
                            Text(habit)
                        }
                    }
                    if !editingExisting {
                        Button("Confirm") {
                            habitConfirmed = true
                        }
                    }
                }

                if habitConfirmed || editingExisting {
                    inputSection("Perceived Rewards", $perceivedRewards, .perceivedRewards)
                    inputSection("Actual Costs", $actualCosts, .actualCosts)
                    inputSection("Better Alternatives", $betterAlternatives, .betterAlternatives)

                    Section(header: Text("Add \(currentCategoryTitle.capitalized)")) {
                        TextField("Type your answer", text: $currentInput)
                            .disabled(isEvaluating)

                        if isEvaluating {
                            ProgressView()
                        } else {
                            Button("Add Item") {
                                Task {
                                    if await validateInput(currentInput, for: currentCategory) {
                                        addItem()
                                    } else {
                                        showingValidationAlert = true
                                    }
                                }
                            }
                            .disabled(currentInput.isEmpty)
                        }
                    }

                    Section {
                        Button("See Comparison") {
                            showComparison = true
                        }
                        .disabled(perceivedRewards.isEmpty || actualCosts.isEmpty || betterAlternatives.isEmpty)

                        Button(editingExisting ? "Update" : "Save") {
                            saveCurrentCheck()
                        }
                    }
                }
            }
            .navigationTitle("Reward Reality")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSavedChecks = true
                    } label: {
                        Image(systemName: "folder")
                    }
                }
            }
            .alert("Validation", isPresented: $showingValidationAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(validationMessage)
            }
            .sheet(isPresented: $showComparison) {
                RewardComparisonView(
                    habit: selectedHabit,
                    perceivedRewards: perceivedRewards,
                    actualCosts: actualCosts,
                    alternatives: betterAlternatives
                )
            }
            .sheet(isPresented: $showingSavedChecks) {
                SavedRewardChecksView(checks: $savedChecks) { check in
                    loadCheck(check)
                    showingSavedChecks = false
                }
            }
            .onAppear {
                loadSavedChecks()
            }
        }
    }

    private func inputSection(_ title: String, _ items: Binding<[String]>, _ category: InputCategory) -> some View {
        Section(header: Text(title)) {
            ForEach(Array(items.wrappedValue.enumerated()), id: \.offset) { index, item in
                HStack {
                    Text(item)
                    Spacer()
                    Button(role: .destructive) {
                        items.wrappedValue.remove(at: index)
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }

            Button("Edit \(title)") {
                currentCategory = category
            }
        }
    }

    private func addItem() {
        switch currentCategory {
        case .perceivedRewards: perceivedRewards.append(currentInput)
        case .actualCosts: actualCosts.append(currentInput)
        case .betterAlternatives: betterAlternatives.append(currentInput)
        }
        currentInput = ""
    }

    private func validateInput(_ input: String, for category: InputCategory) async -> Bool {
        isEvaluating = true
        defer { isEvaluating = false }

        try? await Task.sleep(nanoseconds: 1_000_000_000)

        let words = input.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        if input.count < 12 || words.count < 3 {
            validationMessage = "Please provide more detail."
            return false
        }

        if category == .perceivedRewards && input.lowercased().contains("fun") {
            validationMessage = "Dig deeper – what need is this fulfilling?"
            return false
        }

        return true
    }

    private func saveCurrentCheck() {
        let newCheck = RewardCheck(
            id: editingExisting ? currentCheckId : UUID(),
            habit: selectedHabit,
            perceivedRewards: perceivedRewards,
            actualCosts: actualCosts,
            betterAlternatives: betterAlternatives,
            lastEdited: Date()
        )

        if let index = savedChecks.firstIndex(where: { $0.id == currentCheckId }) {
            savedChecks[index] = newCheck
        } else {
            savedChecks.append(newCheck)
        }

        saveChecksToStorage()
        editingExisting = true
        currentCheckId = newCheck.id
        validationMessage = editingExisting ? "Check updated." : "Check saved."
        showingValidationAlert = true
    }

    private func loadCheck(_ check: RewardCheck) {
        selectedHabit = check.habit
        perceivedRewards = check.perceivedRewards
        actualCosts = check.actualCosts
        betterAlternatives = check.betterAlternatives
        habitConfirmed = true
        editingExisting = true
        currentCheckId = check.id
    }

    private func loadSavedChecks() {
        if let data = UserDefaults.standard.data(forKey: "savedRewardChecks"),
           let decoded = try? JSONDecoder().decode([RewardCheck].self, from: data) {
            savedChecks = decoded.sorted { $0.lastEdited > $1.lastEdited }
        }
    }

    private func saveChecksToStorage() {
        if let encoded = try? JSONEncoder().encode(savedChecks) {
            UserDefaults.standard.set(encoded, forKey: "savedRewardChecks")
        }
    }
}

struct SavedRewardChecksView: View {
    @Binding var checks: [RewardRealityCheckActivity.RewardCheck]
    let onSelect: (RewardRealityCheckActivity.RewardCheck) -> Void

    var body: some View {
        NavigationStack {
            List {
                ForEach(checks) { check in
                    VStack(alignment: .leading) {
                        Text(check.habit)
                            .font(.headline)
                        Text("\(check.perceivedRewards.count) rewards • \(check.actualCosts.count) costs • \(check.betterAlternatives.count) alternatives")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Last edited: \(check.lastEdited.formatted())")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .onTapGesture {
                        onSelect(check)
                    }
                }
                .onDelete { indices in
                    checks.remove(atOffsets: indices)
                    saveChecks()
                }
            }
            .navigationTitle("Saved Checks")
            .toolbar {
                EditButton()
            }
        }
    }

    private func saveChecks() {
        if let encoded = try? JSONEncoder().encode(checks) {
            UserDefaults.standard.set(encoded, forKey: "savedRewardChecks")
        }
    }
}

struct RewardComparisonView: View {
    let habit: String
    let perceivedRewards: [String]
    let actualCosts: [String]
    let alternatives: [String]

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Your Habit")) {
                    Text(habit)
                }

                comparisonSection("Perceived Rewards", items: perceivedRewards)
                comparisonSection("Actual Costs", items: actualCosts)
                comparisonSection("Better Alternatives", items: alternatives)

                Section {
                    Text("The alternatives provide \(alternatives.count)x more value with none of the costs.")
                        .font(.body)
                }
            }
            .navigationTitle("Comparison")
        }
    }

    private func comparisonSection(_ title: String, items: [String]) -> some View {
        Section(header: Text(title)) {
            ForEach(items, id: \.self) { item in
                HStack {
                    Image(systemName: title == "Better Alternatives" ? "checkmark.circle" : "arrow.right")
                    Text(item)
                }
            }
        }
    }
}

