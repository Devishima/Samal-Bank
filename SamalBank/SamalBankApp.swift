import SwiftUI

@main
struct SamalBankApp: App {
    @StateObject private var store = BankStore()
    var body: some Scene {
        WindowGroup {
            RootView().environmentObject(store)
        }
    }
}
