import Foundation


class RewardsEvaluator: ObservableObject {
    @Published var unlockedRewards: Set<String> = []
    @Published var newlyUnlocked: String?
    @Published var goals: [GoalMetric] = []

   

    private let unlockedKey = "UnlockedMobiusRewards"

    let rewards: [String: () -> Bool] = [
        "Animation - 1750346740240": { UserDefaults.standard.integer(forKey: "inviteCount") >= 1 },
        "Animation - 1750346749420": { UserDefaults.standard.integer(forKey: "inviteCount") >= 3 },
        "Animation - 1750346749523": { UserDefaults.standard.integer(forKey: "completedSessionCount") >= 1 },
        "Animation - 1750346766971": { UserDefaults.standard.integer(forKey: "completedSessionCount") >= 5 },
        "Animation - 1750346774873": { UserDefaults.standard.integer(forKey: "completedSessionCount") >= 10 },
        "Animation - 1750346785425": { UserDefaults.standard.integer(forKey: "completedSessionCount") >= 15 }
    ]

    init() {
        loadUnlockedRewards()
        print("🧠 RewardsEvaluator initialized")

    }

    func evaluateAllGoals() {
        print("🧪 evaluateAllGoals called from evaluator: \(Unmanaged.passUnretained(self).toOpaque())")
        let inviteCount = UserDefaults.standard.integer(forKey: "inviteCount")
        let sessionCount = UserDefaults.standard.integer(forKey: "completedSessionCount")
        print("🎯 EVALUATING GOALS — inviteCount: \(inviteCount), completedSessionCount: \(sessionCount)")

        // 🧠 Rebuild goals list
        goals = [
            GoalMetric(id: "invite1", title: "Invite 1 Friend", icon: "person.badge.plus", progress: Double(inviteCount), target: 1),
            GoalMetric(id: "invite3", title: "Invite 3 Friends", icon: "person.3.fill", progress: Double(inviteCount), target: 3),
            GoalMetric(id: "session1", title: "1 Blocking Session", icon: "lock", progress: Double(sessionCount), target: 1),
            GoalMetric(id: "session5", title: "5 Blocking Sessions", icon: "lock.fill", progress: Double(sessionCount), target: 5),
            GoalMetric(id: "session10", title: "10 Blocking Sessions", icon: "lock.shield", progress: Double(sessionCount), target: 10),
            GoalMetric(id: "session15", title: "15 Blocking Sessions", icon: "shield.lefthalf.fill", progress: Double(sessionCount), target: 15)
        ]

        for (animation, condition) in rewards {
            if condition() {
                print("✅ Condition met for \(animation)")
            } else {
                print("❌ Condition NOT met for \(animation)")
            }

            if condition(), !unlockedRewards.contains(animation) {
                unlockedRewards.insert(animation)
                newlyUnlocked = animation
                saveUnlockedRewards()
                print("🏆 NEW reward unlocked: \(animation)")
                break
            }
        }

    }

    func isUnlocked(_ animationName: String) -> Bool {
        unlockedRewards.contains(animationName)
    }

    private func saveUnlockedRewards() {
        let array = Array(unlockedRewards)
        UserDefaults.standard.set(array, forKey: unlockedKey)
    }

    private func loadUnlockedRewards() {
        let saved = UserDefaults.standard.stringArray(forKey: unlockedKey) ?? []
        unlockedRewards = Set(saved)
    }
}

