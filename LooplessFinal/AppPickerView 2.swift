import SwiftUI
import FamilyControls

struct AppPickerView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataModel: LooplessDataModel

    @State private var selection = FamilyActivitySelection()

    var body: some View {
        VStack(spacing: 22) {
            Text("📱 Select Apps to Monitor")
                .font(.custom("AvenirNext-Bold", size: 20))
                .foregroundStyle(
                    LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing)
                )
                .padding(.top)

            FamilyActivityPicker(selection: $selection)
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 16))

            SelectedAppsListView()
                .environmentObject(dataModel)
                .frame(height: 150)

            // ✅ Sleek Gradient Save Button
            Button(action: {
                dataModel.selection = selection
                dataModel.saveSelection()
                dismiss()
            }) {
                Text("✅ Save Selection")
                    .font(.custom("AvenirNext-DemiBold", size: 16))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.05), Color.blue.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.cyan.opacity(0.25), Color.blue.opacity(0.25)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                    )
                    .foregroundColor(.white)
            }

        }
        .padding()
        .background(
            LinearGradient(colors: [.black, .black.opacity(0.9)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
        )
        .onAppear {
            selection = dataModel.selection
        }
    }
}

