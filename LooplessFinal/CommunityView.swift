import SwiftUI

struct CommunityView: View {
    @Binding var showReflectionPopup: Bool
    @State private var showingContacts = false
    @EnvironmentObject var userProfile: UserProfileManager
    @EnvironmentObject var viewModel: CommunityViewModel
    @State private var showDuplicateInviteAlert = false

    var body: some View {
        NavigationStack {
            if !userProfile.hasUsername {
                UsernameSetupView()
            } else {
                List {
                    Section {
                        Button(action: {
                            showingContacts = true
                        }) {
                            HStack {
                                Image(systemName: "person.crop.circle.badge.plus")
                                    .foregroundColor(.accentColor)
                                Text("Invite from Contacts")
                            }
                        }

                        NavigationLink(destination:
                            ForumView()
                                .environmentObject(userProfile)
                                .environmentObject(viewModel)
                        ) {
                            HStack {
                                Image(systemName: "bubble.left.and.bubble.right.fill")
                                    .foregroundColor(.accentColor)
                                Text("Explore the Forum")
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("Community")
                .sheet(isPresented: $showingContacts) {
                    ContactPickerView(showDuplicateInviteAlert: $showDuplicateInviteAlert)
                }
                .alert(isPresented: $showDuplicateInviteAlert) {
                    Alert(
                        title: Text("Already Invited"),
                        message: Text("You've already invited this person. Try inviting someone new."),
                        dismissButton: .default(Text("Got it"))
                    )
                }
            }
        }
        .fullScreenCover(isPresented: $showReflectionPopup) {
            ReflectionPopupView {
                showReflectionPopup = false
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    CommunityView(showReflectionPopup: .constant(false))
        .environmentObject(UserProfileManager())
        .environmentObject(CommunityViewModel())
}

