import SwiftUI
struct DebugMenuView: View {
    @EnvironmentObject var store: BankStore
    @Environment(\.presentationMode) var presentationMode
    @State private var customAmount = ""
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Баланс")) {
                    Text("Текущий: \(store.balance, format: .number.precision(.fractionLength(2))) KZT")
                    Button("+10 000") { store.addFunds(10_000, reason: "Пополнение (10k)") }
                    Button("+50 000") { store.addFunds(50_000, reason: "Пополнение (50k)") }
                    Button("+100 000") { store.addFunds(100_000, reason: "Пополнение (100k)") }
                }
                Section(header: Text("Своя сумма")) {
                    TextField("Сумма", text: $customAmount)
                    Button("Пополнить") { if let a = Decimal(string: customAmount.replacingOccurrences(of: ",", with: ".")) { store.addFunds(a); customAmount = "" } }
                }
                Section(header: Text("Служебное")) {
                    Button("Сбросить данные", role: .destructive) { store.reset() }
                    Button("Выйти из аккаунта", role: .destructive) { UserDefaults.standard.set(false, forKey: "isLoggedIn"); presentationMode.wrappedValue.dismiss() }
                }
            }.navigationTitle("Тест-меню").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Закрыть") { presentationMode.wrappedValue.dismiss() } } }
        }
    }
}
