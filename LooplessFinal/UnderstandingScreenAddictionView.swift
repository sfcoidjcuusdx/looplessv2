import SwiftUI

struct UnderstandingScreenAddictionView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Understanding Screen Addiction")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Learn how screens hijack your dopamine system, alter attention, and reshape your habits.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Spacer()
                    Image(systemName: "bolt.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.cyan)
                        .shadow(radius: 4)
                    Spacer()
                }

                VStack(alignment: .leading, spacing: 20) {
                    SectionView(
                        title: "Dopamine Loops",
                        systemImage: "waveform.path.ecg",
                        description: "Every notification triggers a dopamine spike. Repeated spikes weaken natural motivation and reinforce compulsive checking."
                    )

                    Divider()

                    SectionView(
                        title: "Attention Fragmentation",
                        systemImage: "eye.trianglebadge.exclamationmark",
                        description: "Apps are engineered to fragment focus with infinite scroll, autoplay, and stimuli density."
                    )

                    Divider()

                    SectionView(
                        title: "Digital Dependency",
                        systemImage: "person.2.slash",
                        description: "With excessive use, screens replace boredom with stimulation, making the brain avoid discomfort."
                    )
                }

                NavigationLink(destination: ScreenAddictionQuizView()) {
                    Label("Start Quiz", systemImage: "list.bullet.rectangle.portrait")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.cyan)
                .controlSize(.large)
                .padding(.top, 10)
            }
            .padding()
        }
        .navigationTitle("Screen Health")
        .background(Color(.systemGroupedBackground))
    }
}

struct SectionView: View {
    let title: String
    let systemImage: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundColor(.cyan)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

