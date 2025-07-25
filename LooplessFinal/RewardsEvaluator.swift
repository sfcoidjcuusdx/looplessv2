import Foundation

class RewardsEvaluator: ObservableObject {
    @Published var unlockedRewards: Set<String> = []
    @Published var newlyUnlocked: String?
    @Published var goals: [GoalMetric] = []

    private let unlockedKey = "UnlockedMobiusRewards"

    // 🎯 Rewards now use image names instead of animation names
    let rewards: [String: () -> Bool] = [
        "goldeninf": { UserDefaults.standard.integer(forKey: "inviteCount") >= 1 },
        "otherpurpleinf": { UserDefaults.standard.integer(forKey: "inviteCount") >= 3 },
        "otherredinf": { UserDefaults.standard.integer(forKey: "completedSessionCount") >= 1 },
        "purpleinf": { UserDefaults.standard.integer(forKey: "completedSessionCount") >= 5 },
        "rainbowinf": { UserDefaults.standard.integer(forKey: "completedSessionCount") >= 10 },
        "silverinf": { UserDefaults.standard.integer(forKey: "completedSessionCount") >= 15 }
    ]

    init() {
        loadUnlockedRewards()
    }

    func evaluateAllGoals() {
        let inviteCount = UserDefaults.standard.integer(forKey: "inviteCount")
        let sessionCount = UserDefaults.standard.integer(forKey: "completedSessionCount")

        // 🧠 Update progress-based goal UI
        goals = [
            GoalMetric(id: "invite1", title: "Invite 1 Friend", icon: "person.badge.plus", progress: Double(inviteCount), target: 1),
            GoalMetric(id: "invite3", title: "Invite 3 Friends", icon: "person.3.fill", progress: Double(inviteCount), target: 3),
            GoalMetric(id: "session1", title: "1 Blocking Session", icon: "lock", progress: Double(sessionCount), target: 1),
            GoalMetric(id: "session5", title: "5 Blocking Sessions", icon: "lock.fill", progress: Double(sessionCount), target: 5),
            GoalMetric(id: "session10", title: "10 Blocking Sessions", icon: "lock.shield", progress: Double(sessionCount), target: 10),
            GoalMetric(id: "session15", title: "15 Blocking Sessions", icon: "shield.lefthalf.fill", progress: Double(sessionCount), target: 15)
        ]

        for (imageName, condition) in rewards {
            if condition(), !unlockedRewards.contains(imageName) {
                unlockedRewards.insert(imageName)
                newlyUnlocked = imageName
                saveUnlockedRewards()
                print("🏆 NEW reward unlocked: \(imageName)")
                break
            }
        }
    }

    func isUnlocked(_ imageName: String) -> Bool {
        unlockedRewards.contains(imageName)
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

