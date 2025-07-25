import SwiftUI

struct MobiusRewardsGrid: View {
    @Binding var selectedAnimation: String?
    @ObservedObject var evaluator: RewardsEvaluator

    let rewardImages: [(imageName: String, description: String)] = [
        ("goldeninf", "Invited 1 Friend"),
        ("otherpurpleinf", "Invited 3 Friends"),
        ("otherredinf", "Completed 1 Blocking Session"),
        ("purpleinf", "Completed 5 Blocking Sessions"),
        ("rainbowinf", "Completed 10 Blocking Sessions"),
        ("silverinf", "Completed 15 Blocking Sessions")
    ]

    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    func glowGradient(for imageName: String) -> Gradient {
        let color: Color
        switch imageName {
        case "goldeninf": color = .yellow
        case "silverinf": color = .white
        case "rainbowinf": color = .pink
        case "purpleinf", "otherpurpleinf": color = .purple
        case "otherredinf": color = .red
        default: color = .clear
        }

        return Gradient(stops: [
            .init(color: color.opacity(0.8), location: 0.0),
            .init(color: color.opacity(0.5), location: 0.3),
            .init(color: color.opacity(0.15), location: 0.7),
            .init(color: .clear, location: 1.0)
        ])
    }

    func goalMetric(for imageName: String) -> GoalMetric? {
        switch imageName {
        case "goldeninf": return evaluator.goals.first { $0.id == "invite1" }
        case "otherpurpleinf": return evaluator.goals.first { $0.id == "invite3" }
        case "otherredinf": return evaluator.goals.first { $0.id == "session1" }
        case "purpleinf": return evaluator.goals.first { $0.id == "session5" }
        case "rainbowinf": return evaluator.goals.first { $0.id == "session10" }
        case "silverinf": return evaluator.goals.first { $0.id == "session15" }
        default: return nil
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Earn Mobius Loops")
                        .font(.largeTitle.bold())
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)

                    Text("Unlock powerful symbols of progress")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)

                    Text("More rewards coming soon.")
                        .font(.headline.weight(.medium))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 16)
                .padding(.horizontal, 24)

                LazyVGrid(columns: columns, spacing: 36) {
                    ForEach(rewardImages, id: \.imageName) { reward in
                        let unlocked = evaluator.isUnlocked(reward.imageName)
                        let isSelected = selectedAnimation == reward.imageName
                        let metric = goalMetric(for: reward.imageName)
                        let progress = min(metric?.progress ?? 0, metric?.target ?? 1)
                        let target = metric?.target ?? 1

                        VStack(spacing: 6) {
                            ZStack {
                                TimelineView(.animation(minimumInterval: 0.03)) { context in
                                    let time = context.date.timeIntervalSinceReferenceDate
                                    let movement = CGFloat(sin(time * 1.5)) * 2
                                    let scale = 1 + CGFloat(cos(time * 1.2)) * 0.02

                                    Circle()
                                        .fill(
                                            RadialGradient(
                                                gradient: glowGradient(for: reward.imageName),
                                                center: .center,
                                                startRadius: 2,
                                                endRadius: 90 // large enough to glow without hitting grid edge
                                            )
                                        )
                                        .frame(width: 160, height: 160)
                                        .scaleEffect(unlocked ? scale : 1.0)
                                        .offset(x: unlocked ? movement : 0, y: unlocked ? -movement : 0)
                                        .blur(radius: 10)
                                        .opacity(unlocked ? 1 : 0)
                                        .animation(nil)
                                }

                                if unlocked {
                                    Image(reward.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 120, height: 120)
                                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                                } else {
                                    Image(reward.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 120, height: 120)
                                        .blur(radius: 6)
                                        .brightness(-0.2)
                                        .opacity(0.6)

                                    Image(systemName: "lock.fill")
                                        .font(.title)
                                        .foregroundColor(.gray.opacity(0.8))
                                }
                            }
                            .frame(maxWidth: .infinity, minHeight: 180)

                            Text(reward.description)
                                .font(.body.weight(.semibold))
                                .foregroundColor(unlocked ? .primary : .gray)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, 2)
                                .frame(width: 140)

                            if !unlocked {
                                Spacer().frame(height: 4)

                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color(.systemGray5))
                                        .frame(height: 6)

                                    Capsule()
                                        .fill(Color.cyan)
                                        .frame(width: CGFloat(progress / Double(target)) * 140, height: 6)
                                        .animation(.easeInOut(duration: 0.4), value: progress)
                                }
                                .frame(width: 140)
                                .accessibilityElement()
                                .accessibilityLabel("Progress")
                                .accessibilityValue("\(Int(progress / Double(target) * 100)) percent")
                            } else {
                                Spacer().frame(height: 10)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if unlocked {
                                withAnimation(.easeInOut) {
                                    selectedAnimation = isSelected ? nil : reward.imageName
                                }
                            }
                        }
                    }
                }
                .padding(.top, 12)
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 32)
        }
        .background(Color.white.ignoresSafeArea())
    }
}

