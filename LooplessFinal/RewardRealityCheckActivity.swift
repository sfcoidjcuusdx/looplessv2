//
//  RewardRealityCheckActivity.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/17/25.
//


//
//  RewardRealityCheckActivity.swift
//  loopless
//
//  Created by Ning Ding on 7/10/25.
//

import SwiftUICore
import SwiftUI


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
        
        init(id: UUID = UUID(), habit: String, perceivedRewards: [String], actualCosts: [String], betterAlternatives: [String], lastEdited: Date = Date()) {
            self.id = id
            self.habit = habit
            self.perceivedRewards = perceivedRewards
            self.actualCosts = actualCosts
            self.betterAlternatives = betterAlternatives
            self.lastEdited = lastEdited
        }
    }
    
    private var currentCategoryTitle: String {
        switch currentCategory {
        case .perceivedRewards: return "perceived reward"
        case .actualCosts: return "actual cost"
        case .betterAlternatives: return "better alternative"
        }
    }
    
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 25) {
                    HStack {
                        Text("Reward Reality Check")
                            .font(.largeTitle.weight(.bold))
                            .foregroundStyle(LinearGradient(colors: [.green, .blue], startPoint: .leading, endPoint: .trailing))
                        
                        Spacer()
                        
                        Button(action: {
                            showingSavedChecks = true
                        }) {
                            Image(systemName: "folder.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.bottom, 10)
                    
                    Text("Uncover the true costs of your digital habits and discover more fulfilling alternatives")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Habit Selection
                    VStack(alignment: .leading) {
                        Text(editingExisting ? "Editing habit:" : "1. Select a digital habit:")
                            .font(.headline)
                            .padding(.bottom, 5)
                        
                        Picker("Choose habit", selection: $selectedHabit) {
                            ForEach(commonHabits, id: \.self) { habit in
                                Text(habit).tag(habit)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 120)
                        
                        if !editingExisting {
                            Button("OK") {
                                habitConfirmed = true
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                            .foregroundColor(.black)
                        }
                        
                        if habitConfirmed {
                            Text("Selected: \(selectedHabit)")
                                .foregroundColor(.green)
                                .padding(.top, 5)
                        }
                    }
                    
                    if habitConfirmed || editingExisting {
                        // Input Sections with Deletion
                        VStack(spacing: 20) {
                            InputCard(
                                title: "2. Perceived Rewards",
                                subtitle: "What do you think you gain from \(selectedHabit)?",
                                items: Binding(
                                    get: { self.perceivedRewards },
                                    set: { self.perceivedRewards = $0 }
                                ),
                                isActive: currentCategory == .perceivedRewards,
                                onDelete: { index in
                                    self.perceivedRewards.remove(at: index)
                                }
                            ) {
                                currentCategory = .perceivedRewards
                            }
                            
                            InputCard(
                                title: "3. Actual Costs",
                                subtitle: "What does \(selectedHabit) really cost you?",
                                items: Binding(
                                    get: { self.actualCosts },
                                    set: { self.actualCosts = $0 }
                                ),
                                isActive: currentCategory == .actualCosts,
                                onDelete: { index in
                                    self.actualCosts.remove(at: index)
                                }
                            ) {
                                currentCategory = .actualCosts
                            }
                            
                            InputCard(
                                title: "4. Better Alternatives",
                                subtitle: "What could you do instead that aligns with your values?",
                                items: Binding(
                                    get: { self.betterAlternatives },
                                    set: { self.betterAlternatives = $0 }
                                ),
                                isActive: currentCategory == .betterAlternatives,
                                onDelete: { index in
                                    self.betterAlternatives.remove(at: index)
                                }
                            ) {
                                currentCategory = .betterAlternatives
                            }
                        }
                        
                        // Input Field with Validation
                        HStack {
                            TextField("Add \(currentCategoryTitle)", text: $currentInput)
                                .textFieldStyle(.roundedBorder)
                                .disabled(isEvaluating)
                            
                            if isEvaluating {
                                ProgressView()
                            } else {
                                Button(action: {
                                    Task {
                                        if await validateInput(currentInput, for: currentCategory) {
                                            withAnimation {
                                                addItem()
                                            }
                                        } else {
                                            showingValidationAlert = true
                                        }
                                    }
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title)
                                        .foregroundColor(.green)
                                }
                                .disabled(currentInput.isEmpty)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Action Buttons
                        HStack {
                            if !perceivedRewards.isEmpty && !actualCosts.isEmpty && !betterAlternatives.isEmpty {
                                Button(action: { showComparison = true }) {
                                    Text("See Comparison")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.green)
                                        .clipShape(Capsule())
                                }
                                
                                Button(action: saveCurrentCheck) {
                                    Text(editingExisting ? "Update" : "Save")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.blue)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.top)
                    }
                }
                .padding()
            }
            .blur(radius: isEvaluating ? 2 : 0)
            
            if isEvaluating {
                ProgressView()
                    .scaleEffect(1.5)
            }
        }
        .alert("Dive Deeper", isPresented: $showingValidationAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(validationMessage)
        }
        .background(LinearGradient(colors: [Color.black, Color.green.opacity(0.3)], startPoint: .top, endPoint: .bottom).ignoresSafeArea())
        .sheet(isPresented: $showComparison) {
            RewardComparisonView(
                habit: selectedHabit,
                perceivedRewards: perceivedRewards,
                actualCosts: actualCosts,
                alternatives: betterAlternatives
            )
        }
        .sheet(isPresented: $showingSavedChecks) {
            SavedRewardChecksView(
                checks: $savedChecks,
                onSelect: { check in
                    loadCheck(check)
                    showingSavedChecks = false
                }
            )
        }
        .onAppear {
            loadSavedChecks()
        }
    }
    
    private func addItem() {
        guard !currentInput.isEmpty else { return }
        
        switch currentCategory {
        case .perceivedRewards:
            perceivedRewards.append(currentInput)
        case .actualCosts:
            actualCosts.append(currentInput)
        case .betterAlternatives:
            betterAlternatives.append(currentInput)
        }
        
        currentInput = ""
    }
    
    private func validateInput(_ input: String, for category: InputCategory) async -> Bool {
        isEvaluating = true
        defer { isEvaluating = false }
        
        // Simulate AI validation
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            let minimumThoughtfulLength = 12
            let minimumWords = 3
            let words = input.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            
            if input.count < minimumThoughtfulLength || words.count < minimumWords {
                validationMessage = "Please provide more detail. How exactly does this affect you?"
                return false
            }
            
            switch category {
            case .perceivedRewards:
                if input.lowercased().contains("like") || input.lowercased().contains("fun") {
                    validationMessage = "Dig deeper - what need is this really fulfilling?"
                    return false
                }
            case .actualCosts:
                if words.count < 4 {
                    validationMessage = "Consider both immediate and long-term costs"
                    return false
                }
            case .betterAlternatives:
                if input.lowercased().contains("nothing") {
                    validationMessage = "There's always an alternative. What would your best self do?"
                    return false
                }
            }
            
            return true
        } catch {
            validationMessage = "Verification unavailable. Please ensure your answer is thoughtful."
            return true
        }
    }
    
    private func saveCurrentCheck() {
        let newCheck = RewardCheck(
            id: editingExisting ? currentCheckId : UUID(),
            habit: selectedHabit,
            perceivedRewards: perceivedRewards,
            actualCosts: actualCosts,
            betterAlternatives: betterAlternatives
        )
        
        if let index = savedChecks.firstIndex(where: { $0.id == currentCheckId }) {
            savedChecks[index] = newCheck
        } else {
            savedChecks.append(newCheck)
        }
        
        saveChecksToStorage()
        editingExisting = true
        currentCheckId = newCheck.id
        
        // Show confirmation
        validationMessage = editingExisting ? "Check updated!" : "Check saved!"
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
        // In a real app, you would load from UserDefaults or a database
        // This is a simplified version
        if let data = UserDefaults.standard.data(forKey: "savedRewardChecks"),
           let decoded = try? JSONDecoder().decode([RewardCheck].self, from: data) {
            savedChecks = decoded.sorted { $0.lastEdited > $1.lastEdited }
            
            if let latestCheck = savedChecks.first {
                loadCheck(latestCheck)
            }
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
        NavigationView {
            List {
                ForEach(checks) { check in
                    VStack(alignment: .leading) {
                        Text(check.habit)
                            .font(.headline)
                        Text("\(check.perceivedRewards.count) rewards • \(check.actualCosts.count) costs • \(check.betterAlternatives.count) alternatives")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("Last edited: \(check.lastEdited.formatted())")
                            .font(.caption)
                            .foregroundColor(.gray)
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
    }
    
    private func saveChecks() {
        if let encoded = try? JSONEncoder().encode(checks) {
            UserDefaults.standard.set(encoded, forKey: "savedRewardChecks")
        }
    }
}

struct InputCard: View {
    let title: String
    let subtitle: String
    @Binding var items: [String]
    let isActive: Bool
    let onDelete: (Int) -> Void
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(isActive ? .green : .white)
                    
                    Spacer()
                    
                    Image(systemName: isActive ? "checkmark.circle.fill" : "plus.circle")
                        .foregroundColor(isActive ? .green : .gray)
                }
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, 5)
                
                if !items.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(items.enumerated()), id: \.element) { index, item in
                            HStack {
                                Text("• \(item)")
                                    .foregroundColor(.white)
                                Spacer()
                                Button {
                                    onDelete(index)
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red.opacity(0.7))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(isActive ? Color.white.opacity(0.1) : Color.clear)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isActive ? Color.green : Color.gray.opacity(0.5), lineWidth: 1)
            )
        }
    }
}

struct RewardComparisonView: View {
    let habit: String
    let perceivedRewards: [String]
    let actualCosts: [String]
    let alternatives: [String]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                Text("Reward Reality Check")
                    .font(.title.bold())
                    .foregroundColor(.green)
                
                VStack(alignment: .leading) {
                    Text("Your Habit:")
                        .font(.headline)
                    Text(habit)
                        .padding()
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(10)
                }
                
                ComparisonSection(
                    title: "Perceived Rewards",
                    items: perceivedRewards,
                    color: .blue
                )
                
                ComparisonSection(
                    title: "Actual Costs",
                    items: actualCosts,
                    color: .red
                )
                
                ComparisonSection(
                    title: "Better Alternatives",
                    items: alternatives,
                    color: .green
                )
                
                Text("The alternatives provide \(alternatives.count)X more value with none of the costs")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
            }
            .padding()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct ComparisonSection: View {
    let title: String
    let items: [String]
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundColor(color)
            
            ForEach(items, id: \.self) { item in
                HStack {
                    Image(systemName: title == "Better Alternatives" ? "checkmark.circle.fill" : "arrow.right")
                        .foregroundColor(color)
                    Text(item)
                        .foregroundColor(.white)
                }
                .padding(.vertical, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(color.opacity(0.5), lineWidth: 1)
        )
    }
}
