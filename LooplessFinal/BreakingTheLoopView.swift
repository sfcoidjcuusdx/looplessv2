import SwiftUI

struct BreakingTheLoopView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Breaking the Loop")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Now that you recognize loops, it’s time to rewrite your response pathways with intentional action.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Spacer()
                    Image(systemName: "wand.and.stars.inverse")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.cyan)
                        .shadow(radius: 4)
                    Spacer()
                }

                VStack(alignment: .leading, spacing: 20) {
                    SectionView(
                        title: "The Interrupt",
                        systemImage: "pause.circle",
                        description: "Before reacting, insert a 5-second pause. Say: “Do I really want this?”"
                    )

                    Divider()

                    SectionView(
                        title: "Replace with Routines",
                        systemImage: "figure.walk.circle",
                        description: "Create replacement behaviors: walk, stretch, breathwork. Make them accessible."
                    )

                    Divider()

                    SectionView(
                        title: "Reflect Regularly",
                        systemImage: "book.closed",
                        description: "What worked? What didn’t? Daily journaling increases loop-breaking success."
                    )
                }

                NavigationLink(destination: LoopBreakingQuizView()) {
                    Label("Practice Response Quiz", systemImage: "checkmark.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.cyan)
                .controlSize(.large)
                .padding(.top, 10)
            }
            .padding()
        }
        .navigationTitle("Loop Rewiring")
        .background(Color(.systemGroupedBackground))
    }
}
