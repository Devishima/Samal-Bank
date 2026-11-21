import SwiftUI
struct RootView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    var body: some View {
        Group {
            if isLoggedIn { HomeView() } else { LoginView() }
        }.animation(.easeInOut, value: isLoggedIn)
    }
}
