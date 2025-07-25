import SwiftUI
import FamilyControls

struct HomeView: View {
    @Binding var selectedTab: AppTab
    @Binding var showReflectionPopup: Bool
    @EnvironmentObject var dataModel: LooplessDataModel
    @EnvironmentObject var sessionManager: BlockingSessionManager

    @State private var showingPicker = false
    @State private var isRequestingAuthorization = false
    @State private var authorizationDeniedAlert = false
    @State private var showLoadTip = false

    private let appGroupDefaults = UserDefaults(suiteName: "group.crew.LooplessFinal.sharedData")

    var body: some View {
        ZStack {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Logo top-left
                        HStack {
                            Image("LOGO 1-4")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120)
                            Spacer()
                                                        NavigationLink(destination: SettingsView()) {
                                                            Image(systemName: "gearshape")
                                                                .imageScale(.large)
                                                                .foregroundColor(.primary)
                                                        }
                                                    }
                        .padding(.top)

                        ExampleView()
                            .frame(height: 120)
                        
                        MetricSummaryReportView()
                            .frame(height: 150)

                        AppBreakdownReportView()
                            .frame(height: 140)

                        WeeklyBreakdownReportView()
                            .frame(height: 250)

                        VStack(alignment: .leading, spacing: 16) {
                            Button(action: {
                                requestAuthorizationAndShowPicker()
                            }) {
                                Label("Select Apps to Monitor & Block", systemImage: "app.badge")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(.borderedProminent)

                            NavigationLink(destination: ScheduleBlockingView().environmentObject(dataModel)) {
                                Label("Create a Custom Blocking Schedule", systemImage: "calendar.badge.clock")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(.bordered)
                            
                            // ✅ NEW BUTTON
                                NavigationLink(destination: AppLimitPickerView().environmentObject(dataModel)) {
                                    Label("Set Daily App Time Limits", systemImage: "clock.badge.exclamationmark")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .buttonStyle(.bordered)
                            
                            AppLimitListInlineView()
                                .environmentObject(dataModel)
                                .padding(.top, 4)
                            PresetBlockingCardsInlineView()
                                .environmentObject(dataModel)
                                .environmentObject(sessionManager) // Ensure this is passed from parent!


                                                    }
                        .padding(.top)
                    }
                    .padding()
                }
                .background(.background)
                .navigationBarHidden(true) // Removes "Overview" title
                .sheet(isPresented: $showingPicker) {
                    AppPickerView().environmentObject(dataModel)
                }
                .alert("Screen Time Access Denied", isPresented: $authorizationDeniedAlert) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text("You need to grant Screen Time access to select apps to monitor and block.")
                }
                .onAppear {
                    showLoadTip = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                        withAnimation { showLoadTip = false }
                    }
                }
            }
            .fullScreenCover(isPresented: $showReflectionPopup) {
                        ReflectionPopupView {
                            showReflectionPopup = false
                        }
                        .navigationBarHidden(true)
                    }

            // Tip Popup
            if showLoadTip {
                VStack {
                    Spacer()
                    Text("Tip: If the view doesn't load, exit and reopen the app. This refreshes Screen Time.")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                        .padding(.bottom, 80)
                        .transition(.opacity)
                        .zIndex(1)
                }
                .padding()
                .animation(.easeInOut(duration: 0.3), value: showLoadTip)
            }

            // Reflection Popup
           
        }
    }

    private func requestAuthorizationAndShowPicker() {
        isRequestingAuthorization = true

        Task {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                let status = AuthorizationCenter.shared.authorizationStatus
                isRequestingAuthorization = false

                if status == .approved {
                    showingPicker = true
                } else {
                    authorizationDeniedAlert = true
                }
            } catch {
                isRequestingAuthorization = false
                authorizationDeniedAlert = true
            }
        }
    }
}

