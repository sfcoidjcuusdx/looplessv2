import SwiftUI
import FamilyControls

struct HomeView: View {
    @Binding var selectedTab: AppTab
    @Binding var showReflectionPopup: Bool
    @EnvironmentObject var dataModel: LooplessDataModel
    @StateObject private var stopwatch = StopwatchManager()

    @State private var showingPicker = false
    @State private var pulse = false
    @State private var isRequestingAuthorization = false
    @State private var authorizationDeniedAlert = false
    @State private var showLoadTip = false // 👈 Tip popup toggle

    private let appGroupDefaults = UserDefaults(suiteName: "group.crew.LooplessFinal.sharedData")

    var body: some View {
        ZStack {
            NavigationStack {
                VStack(spacing: 0) {

                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Spacer()
                                Image("LOGO 2-2")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 140)
                                Spacer()
                            }
                            .padding(.top, 12)

                            ExampleView()
                                .frame(height: 120)
                                .padding(.vertical, 2)

                            MetricSummaryReportView()
                                .frame(height: 130)
                                .padding(.vertical, 2)

                            AppBreakdownReportView()
                                .frame(height: 140)
                                .padding(.vertical, 2)

                            WeeklyBreakdownReportView()
                                .frame(height: 190)
                                .padding(.vertical, 2)

                            VStack(alignment: .leading, spacing: 24) {
                                Button(action: {
                                    showingPicker = true
                                }) {
                                    HStack {
                                        Image(systemName: "app.badge")
                                            .foregroundStyle(LinearGradient(colors: [.cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        Text("Select Apps to Monitor & Block")
                                            .font(.custom("AvenirNext-Medium", size: 14))
                                            .foregroundStyle(LinearGradient(colors: [.cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color.black.opacity(0.9))
                                            .overlay(RoundedRectangle(cornerRadius: 14)
                                                .stroke(LinearGradient(colors: [Color.cyan.opacity(0.25), Color.blue.opacity(0.25)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
                                    )
                                    .shadow(color: Color.blue.opacity(0.2), radius: 6, x: 0, y: 3)
                                }

                                NavigationLink(destination: ScheduleBlockingView().environmentObject(dataModel)) {
                                    HStack {
                                        Image(systemName: "calendar.badge.clock")
                                            .foregroundStyle(LinearGradient(colors: [.cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        Text("Apply Blocking Based on Schedule")
                                            .font(.custom("AvenirNext-Medium", size: 14))
                                            .foregroundStyle(LinearGradient(colors: [.cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color.black.opacity(0.9))
                                            .overlay(RoundedRectangle(cornerRadius: 14)
                                                .stroke(LinearGradient(colors: [Color.cyan.opacity(0.25), Color.blue.opacity(0.25)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
                                    )
                                    .shadow(color: Color.blue.opacity(0.2), radius: 6, x: 0, y: 3)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 24)
                        }
                    }
                }
                .background(Color.black.ignoresSafeArea())
                .preferredColorScheme(.dark)
                .onAppear {
                    showLoadTip = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                        withAnimation { showLoadTip = false }
                    }
                }
                .sheet(isPresented: $showingPicker) {
                    AppPickerView().environmentObject(dataModel)
                }
                .alert("Screen Time Access Denied", isPresented: $authorizationDeniedAlert) {
                    Button("OK") {}
                } message: {
                    Text("You need to grant Screen Time access to select apps to monitor and block.")
                }
            }

            if showLoadTip {
                VStack {
                    Spacer()
                    Text("💡 Tip: If the view doesn't load, exit and reopen the app.\nThis refreshes the Screen Time extension.")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.black.opacity(0.85)))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.blue.opacity(0.3), lineWidth: 1))
                        .foregroundColor(.white)
                        .padding(.bottom, 80)
                        .transition(.opacity)
                        .zIndex(2)
                }
                .padding()
                .animation(.easeInOut(duration: 0.3), value: showLoadTip)
            }

            if showReflectionPopup {
                Color.black.opacity(0.4).ignoresSafeArea()
                ReflectionPopupView {
                    showReflectionPopup = false
                }
                .frame(maxWidth: 350)
                .padding()
                .transition(.scale)
                .zIndex(3)
            }
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

