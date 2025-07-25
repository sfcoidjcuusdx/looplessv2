import SwiftUI

struct UsernameSetupView: View {
    @EnvironmentObject var userProfile: UserProfileManager
    @State private var newUsername = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Choose Your Username")) {
                    TextField("e.g. looplessFan23", text: $newUsername)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }

                Section {
                    Button("Save Username") {
                        userProfile.username = newUsername.trimmingCharacters(in: .whitespaces)
                    }
                    .disabled(newUsername.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .navigationTitle("Username")
        }
    }
}

