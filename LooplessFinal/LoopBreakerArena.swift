//
//  LoopBreakerArena.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/17/25.
//


//
//  LoopBreakerArena.swift
//  loopless
//
//  Created by Ning Ding on 7/11/25.
//

import SwiftUI

struct LoopBreakerArena: View {
    // Game states
    enum GameState {
        case tutorial, playing, success, failure
    }
    
    @State private var gameState: GameState = .tutorial
    @State private var score = 0
    @State private var timeRemaining = 60
    @State private var showFeedback = false
    @State private var feedbackMessage = ""
    @State private var feedbackColor: Color = .green
    @State private var showCelebration = false
    @State private var previousResponses: [PreviousResponse] = []
    @State private var showSummary = false
    @State private var currentRound = 0
    @State private var totalRounds = 5
    @State private var currentResponseOptions: [Response] = []
    
    // Game elements
    @State private var triggers: [Trigger] = []
    @State private var currentHabit: Habit?
    @State private var selectedResponse: Response?
    
    // Models
    struct Trigger: Identifiable {
        let id = UUID()
        let type: String
        let position: CGPoint
        var active: Bool = true
    }
    
    struct Habit: Identifiable {
        let id = UUID()
        let name: String
        let description: String
        let rewardValue: Int
    }
    
    struct Response: Identifiable {
        let id = UUID()
        let type: String
        let description: String
        let effectiveness: Int
    }
    
    struct PreviousResponse: Identifiable, Codable {
        let id = UUID()
        let habit: String
        let response: String
        let effectiveness: Int
        let date: Date
    }
    
    // Game data
    let habits = [
        Habit(name: "Endless Scrolling", description: "You automatically open social media when bored", rewardValue: 3),
        Habit(name: "Notification Checking", description: "You check your phone with every ping", rewardValue: 2),
        Habit(name: "Stress Snacking", description: "You eat junk food when anxious", rewardValue: 4),
        Habit(name: "Procrastination", description: "You delay important tasks with distractions", rewardValue: 3),
        Habit(name: "Negative Self-Talk", description: "You criticize yourself excessively", rewardValue: 2)
    ]
    
    let allResponses = [
        Response(type: "⏸️ Pause", description: "Take 5 deep breaths before acting", effectiveness: 3),
        Response(type: "🚶‍♂️ Replace", description: "Do some physical activity instead", effectiveness: 4),
        Response(type: "📝 Journal", description: "Write down what you're feeling", effectiveness: 5),
        Response(type: "💧 Hydrate", description: "Drink a glass of water mindfully", effectiveness: 3),
        Response(type: "🎯 Focus", description: "Do five senses grounding", effectiveness: 5),
        Response(type: "🧘 Meditate", description: "Do a 1-minute mindfulness exercise", effectiveness: 5),
        Response(type: "📱 Remove", description: "Put your phone in another room", effectiveness: 4),
        Response(type: "🤷 Ignore", description: "Pretend it didn't happen", effectiveness: 1),
        Response(type: "🔁 Repeat", description: "Do the habit anyway", effectiveness: 0),
        Response(type: "😤 Resist", description: "White-knuckle through the urge", effectiveness: 2)
    ]
    
    // Timer
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(colors: [Color.black, Color.red.opacity(0.3)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            // Game UI
            VStack {
                // Header
                HStack {
                    Text("Score: \(score)")
                        .font(.title2.weight(.bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 6)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(timeRemaining)/60)
                            .stroke(Color.red, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                        
                        Text("\(timeRemaining)")
                            .font(.headline.weight(.bold))
                    }
                    .frame(width: 40, height: 40)
                }
                .padding()
                
                // Main game area
                ZStack {
                    // Floating triggers
                    ForEach(triggers.filter { $0.active }) { trigger in
                        Image(systemName: triggerIcon(for: trigger.type))
                            .font(.system(size: 30))
                            .foregroundColor(.red)
                            .position(trigger.position)
                            .onTapGesture { handleTriggerTap(trigger) }
                            .wiggle()
                    }
                    
                    // Current habit display
                    if let habit = currentHabit {
                        VStack(spacing: 16) {
                            Text("Habit Triggered!")
                                .font(.title3.weight(.bold))
                                .foregroundColor(.red)
                            
                            Text(habit.name)
                                .font(.title2.weight(.bold))
                            
                            Text(habit.description)
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .padding(.vertical, 8)
                            
                            // Response options (using the pre-selected random options)
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(currentResponseOptions) { response in
                                    Button(action: {
                                        selectedResponse = response
                                        evaluateResponse(habit: habit, response: response)
                                    }) {
                                        VStack {
                                            Text(response.type)
                                                .font(.title3)
                                            Text(response.description)
                                                .font(.caption)
                                                .multilineTextAlignment(.center)
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(selectedResponse?.id == response.id ? Color.green.opacity(0.2) : Color.white.opacity(0.05))
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(selectedResponse?.id == response.id ? Color.green : Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                    }
                                }
                            }
                            
                            if showFeedback {
                                Text(feedbackMessage)
                                    .font(.headline)
                                    .foregroundColor(feedbackColor)
                                    .padding()
                                    .transition(.opacity)
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(15)
                        .transition(.scale)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .blur(radius: gameState == .tutorial ? 5 : 0)
            
            // Tutorial overlay
            if gameState == .tutorial {
                TutorialView(startGame: {
                    withAnimation {
                        gameState = .playing
                        startGame()
                    }
                })
            }
            
            // Celebration effects
            if showCelebration {
                ConfettiView()
                    .allowsHitTesting(false)
            }
            
            // Summary view
            if showSummary {
                GameSummaryView(
                    score: score,
                    responses: previousResponses,
                    playAgain: {
                        showSummary = false
                        startGame()
                    }
                )
                .transition(.move(edge: .bottom))
            }
        }
        .onReceive(timer) { _ in
            if gameState == .playing {
                if timeRemaining > 0 {
                    timeRemaining -= 1
                    
                    // Randomly spawn triggers
                    if triggers.filter({ $0.active }).count < 3 && Int.random(in: 0...10) > 7 {
                        spawnTrigger()
                    }
                } else {
                    endGame(success: false)
                }
            }
        }
        .onAppear {
            loadPreviousResponses()
            if !previousResponses.isEmpty {
                showSummary = true
            }
        }
    }
    
    // Game functions
    private func startGame() {
        timeRemaining = 60
        score = 0
        currentRound = 0
        triggers.removeAll()
        currentHabit = nil
        selectedResponse = nil
        currentResponseOptions = []
        previousResponses.removeAll()
        
        // Initial triggers
        for _ in 0..<3 {
            spawnTrigger()
        }
    }
    
    private func spawnTrigger() {
        let triggerTypes = ["bell", "exclamationmark.bubble", "brain.head.profile", "heart"]
        let newTrigger = Trigger(
            type: triggerTypes.randomElement()!,
            position: CGPoint(
                x: CGFloat.random(in: 50...UIScreen.main.bounds.width-50),
                y: CGFloat.random(in: 150...UIScreen.main.bounds.height/2)
            )
        )
        
        withAnimation {
            triggers.append(newTrigger)
        }
        
        // Remove after some time if not tapped
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if let index = triggers.firstIndex(where: { $0.id == newTrigger.id }) {
                if triggers[index].active {
                    withAnimation {
                        triggers.remove(at: index)
                    }
                }
            }
        }
    }
    
    private func handleTriggerTap(_ trigger: Trigger) {
        guard currentHabit == nil else { return }
        
        if let index = triggers.firstIndex(where: { $0.id == trigger.id }) {
            triggers[index].active = false
        }
        
        // Set random current habit and generate response options
        currentHabit = habits.randomElement()
        currentResponseOptions = allResponses.shuffled().prefix(4).map { $0 }
    }
    
    private func evaluateResponse(habit: Habit, response: Response) {
        let pointsEarned = habit.rewardValue * response.effectiveness
        score += pointsEarned
        
        // Save the response
        let previousResponse = PreviousResponse(
            habit: habit.name,
            response: "\(response.type) - \(response.description)",
            effectiveness: response.effectiveness,
            date: Date()
        )
        previousResponses.append(previousResponse)
        saveResponses()
        
        // Provide feedback
        if response.effectiveness >= 3 {
            feedbackMessage = "Great choice! +\(pointsEarned) points"
            feedbackColor = .green
        } else if response.effectiveness >= 1 {
            feedbackMessage = "Could be better. +\(pointsEarned) points"
            feedbackColor = .yellow
        } else {
            feedbackMessage = "That reinforces the loop! +\(pointsEarned) points"
            feedbackColor = .red
        }
        
        withAnimation {
            showFeedback = true
        }
        
        // Clear after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showFeedback = false
                currentHabit = nil
                selectedResponse = nil
                currentResponseOptions = []
                currentRound += 1
                
                if currentRound < totalRounds {
                    // Spawn new triggers for next round
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        for _ in 0..<3 {
                            spawnTrigger()
                        }
                    }
                } else {
                    endGame(success: true)
                    showSummary = true
                }
            }
        }
    }
    
    private func endGame(success: Bool) {
        gameState = success ? .success : .failure
        
        if success {
            showCelebration = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showCelebration = false
            }
        }
    }
    
    private func triggerIcon(for type: String) -> String {
        switch type {
        case "bell": return "bell.fill"
        case "exclamationmark.bubble": return "exclamationmark.bubble.fill"
        case "brain.head.profile": return "brain.head.profile"
        case "heart": return "heart.fill"
        default: return "questionmark"
        }
    }
    
    // Persistence functions
    private func saveResponses() {
        if let encoded = try? JSONEncoder().encode(previousResponses) {
            UserDefaults.standard.set(encoded, forKey: "savedLoopBreakerResponses")
        }
    }
    
    private func loadPreviousResponses() {
        if let data = UserDefaults.standard.data(forKey: "savedLoopBreakerResponses"),
           let decoded = try? JSONDecoder().decode([PreviousResponse].self, from: data) {
            previousResponses = decoded
        }
    }
}

// MARK: - Subviews

struct TutorialView: View {
    let startGame: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to Loop Breaker Arena!")
                .font(.largeTitle.weight(.bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 16) {
                TutorialStep(icon: "target", title: "Spot Triggers", description: "Tap flashing triggers as they appear")
                TutorialStep(icon: "brain.head.profile", title: "Recognize Habits", description: "Each trigger activates a habit loop")
                TutorialStep(icon: "hand.raised", title: "Choose Wisely", description: "Select the best response to break the loop")
                TutorialStep(icon: "star.fill", title: "Earn Points", description: "Better responses earn more points")
            }
            .padding()
            .background(Color.black.opacity(0.7))
            .cornerRadius(15)
            
            Button(action: startGame) {
                Text("Start Breaking Loops!")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.black)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
        }
        .padding()
    }
}

struct TutorialStep: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.red)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
}

struct GameSummaryView: View {
    let score: Int
    let responses: [LoopBreakerArena.PreviousResponse]
    let playAgain: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Game Complete!")
                .font(.largeTitle.weight(.bold))
                .foregroundColor(.green)
            
            Text("Your Score: \(score)")
                .font(.title)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(responses) { response in
                        VStack(alignment: .leading) {
                            Text(response.habit)
                                .font(.headline)
                            Text(response.response)
                                .font(.subheadline)
                            Text("Effectiveness: \(response.effectiveness)/5")
                                .foregroundColor(effectivenessColor(response.effectiveness))
                        }
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(10)
                    }
                }
            }
            
            Button(action: playAgain) {
                Text("Play Again")
                    .font(.headline.weight(.bold))
                    .foregroundColor(.black)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
        .background(Color.black.opacity(0.9))
        .cornerRadius(20)
        .padding()
    }
    
    private func effectivenessColor(_ score: Int) -> Color {
        switch score {
        case 4...5: return .green
        case 2...3: return .yellow
        default: return .red
        }
    }
}

struct ConfettiView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        let emitter = CAEmitterLayer()
        emitter.emitterShape = .line
        emitter.emitterPosition = CGPoint(x: view.bounds.width/2, y: -10)
        emitter.emitterSize = CGSize(width: view.bounds.width, height: 1)
        
        let colors: [UIColor] = [.systemRed, .systemGreen, .systemBlue, .systemYellow, .systemPink]
        var cells = [CAEmitterCell]()
        
        for color in colors {
            let cell = CAEmitterCell()
            cell.contents = UIImage(systemName: "star.fill")?.cgImage
            cell.color = color.cgColor
            cell.birthRate = 3
            cell.lifetime = 10
            cell.lifetimeRange = 2
            cell.velocity = 100
            cell.velocityRange = 50
            cell.emissionRange = .pi
            cell.spin = 2
            cell.spinRange = 3
            cell.scale = 0.2
            cell.scaleRange = 0.1
            cells.append(cell)
        }
        
        emitter.emitterCells = cells
        view.layer.addSublayer(emitter)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

// MARK: - Extensions

extension View {
    func wiggle() -> some View {
        modifier(WiggleModifier())
    }
}

struct WiggleModifier: ViewModifier {
    @State private var isWiggling = false
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(isWiggling ? 5 : -5))
            .animation(Animation.easeInOut(duration: 0.25).repeatForever(autoreverses: true), value: isWiggling)
            .onAppear { isWiggling = true }
    }
}

// MARK: - Preview

struct LoopBreakerArena_Previews: PreviewProvider {
    static var previews: some View {
        LoopBreakerArena()
    }
}
