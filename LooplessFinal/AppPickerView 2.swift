import SwiftUI
import FamilyControls

struct AppPickerView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataModel: LooplessDataModel

    @State private var selection = FamilyActivitySelection()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Select Apps to Monitor")) {
                    FamilyActivityPicker(selection: $selection)
                        .frame(height: 300)
                }

                Section(header: Text("Selected Apps")) {
                    SelectedAppsListView()
                        .environmentObject(dataModel)
                        .frame(height: 150)
                }

                Section {
                    Button("Save Selection") {
                        dataModel.selection = selection
                        dataModel.saveSelection()
                        dismiss()
                    }
                }
            }
            .navigationTitle("App Monitoring")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                selection = dataModel.selection
            }
        }
    }
}

