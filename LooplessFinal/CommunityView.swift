//
//  CommunityView.swift
//  LooplessFinal
//
//  Created by rafiq kutty on 7/8/25.
//

import SwiftUI

struct CommunityView: View {
    @Binding var showReflectionPopup: Bool
    @State private var showingContacts = false
    @EnvironmentObject var userProfile: UserProfileManager
    @EnvironmentObject var viewModel: CommunityViewModel // ✅ Not @StateObject
    @State private var showDuplicateInviteAlert = false


    var body: some View {
        if !userProfile.hasUsername {
            UsernameSetupView()
        } else {
            ZStack {
                // 🌌 Gradient Background
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color(.darkGray)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 30) {
                    Text("Community")
                        .font(.custom("AvenirNext-Bold", size: 32))
                        .foregroundColor(.white)
                        .padding(.top, 40)
                        .padding(.horizontal)

                    Spacer()

                    VStack(spacing: 24) {
                        // ✉️ Invite Button Card
                        Button(action: {
                            showingContacts = true
                        }) {
                            HStack {
                                Image(systemName: "person.crop.circle.badge.plus")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .padding(14)
                                    .background(Color.purple.opacity(0.2))
                                    .clipShape(Circle())
                                    .shadow(radius: 6)

                                Text("Invite from Contacts")
                                    .font(.custom("AvenirNext-Medium", size: 18))
                                    .foregroundColor(.white)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.05))
                                    .background(.ultraThinMaterial)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.purple.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                        }

                        // 💬 Forum Button Card
                        NavigationLink(destination:
                            ForumView()
                                .environmentObject(userProfile)
                                .environmentObject(viewModel)
                        ) {
                            HStack {
                                Image(systemName: "bubble.left.and.bubble.right.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .padding(14)
                                    .background(Color.purple.opacity(0.2))
                                    .clipShape(Circle())
                                    .shadow(radius: 6)

                                Text("Explore the Forum")
                                    .font(.custom("AvenirNext-Medium", size: 18))
                                    .foregroundColor(.white)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.05))
                                    .background(.ultraThinMaterial)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.purple.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                }

                // 🌿 Reflection Popup
                if showReflectionPopup {
                    Color.black.opacity(0.4).ignoresSafeArea()

                    ReflectionPopupView {
                        showReflectionPopup = false
                    }
                    .frame(maxWidth: 350)
                    .padding()
                    .transition(.scale)
                    .zIndex(1)
                }
            }
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


            .navigationBarHidden(true)
        }
    }
}

// MARK: - Preview

#Preview {
    CommunityView(showReflectionPopup: .constant(false))
        .environmentObject(UserProfileManager())
        .environmentObject(CommunityViewModel())
}

