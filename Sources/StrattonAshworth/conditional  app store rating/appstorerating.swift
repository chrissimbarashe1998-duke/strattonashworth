import SwiftUI
import StoreKit

struct AppRatingContentView: View {
    var body: some View {
        List {
            NavigationLink("Detail View") {
                Text("Hello from HoneyBird")
                .onAppear {
                    let currentCount = UserDefaults.standard.integer(forKey: "launchCount")
                    UserDefaults.standard.set(currentCount + 1, forKey: "launchCount")
                }
            }
        }
        .navigationTitle("App Store Rating")
        .presentAppRating(
            initialCondition: {
                let count = UserDefaults.standard.integer(forKey: "launchCount")
                return count >= 2
            },
            askLaterCondition: {
                // Your ask later condition logic here
                let count = UserDefaults.standard.integer(forKey: "launchCount")
                return count >= 4
            }
        )
}

extension View {
    @ViewBuilder func presentAppRating(
        initialCondition: @escaping () async -> Bool,
        askLaterCondition: @escaping () async -> Bool
    ) -> some View {
        self.modifier(
            AppStoreRatingModifier(
                initialCondition: initialCondition,
                askLaterCondition: askLaterCondition
            )
        )
    }
}

fileprivate struct AppStoreRatingModifier: ViewModifier {
    let initialCondition: () async -> Bool
    let askLaterCondition: () async -> Bool
    @AppStorage("isRatingInteractionComplete") private var isCompleted: Bool = false
    @AppStorage("isInitialPromptComplete") private var isInitialPromptShown: Bool = false
    @State private var showAlert: Bool = false
    @Environment(\.requestReview) private var requestReview

    func body(content: Content) -> some View {
        content
            .task {
                guard !isCompleted else { return }

                let condition = isInitialPromptShown ? (await askLaterCondition()) : (await initialCondition())

                if condition {
                    showAlert = true
                }
            }
            .alert("Would you like to rate our app?", isPresented: $showAlert) {
                Button(isInitialPromptShown ? "Yes" : "Yes Continue") {
                    requestReview()
                    isCompleted = true
                }
                .keyboardShortcut(.defaultAction)

                if isInitialPromptShown {
                    Button("Nope", role: .cancel) {
                        isCompleted = true
                    }
                } else {
                    Button("Ask Me Later", role: .cancel) {
                        isInitialPromptShown = true
                    }

                    Button("No, Thanks", role: .destructive) {
                        isCompleted = true
                    }
                }
                
            }
    }
}   