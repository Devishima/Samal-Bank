import SwiftUI
struct TransferView: View {
    @EnvironmentObject var store: BankStore
    @Environment(\.presentationMode) var presentationMode
    @State private var recipient = ""
    @State private var amountText = ""
    @State private var note = ""
    @State private var showSuccess = false
    @State private var showError = false
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Получатель")) { TextField("Имя или номер карты", text: $recipient) }
                Section(header: Text("Сумма")) { TextField("0.00", text: $amountText) }
                Section(header: Text("Комментарий")) { TextField("Необязательно", text: $note) }
                Section {
                    Button {
                        if let amount = Decimal(string: amountText.replacingOccurrences(of: ",", with: ".")), store.transfer(to: recipient.isEmpty ? "Неизвестный" : recipient, amount: amount, note: note) { showSuccess = true } else { showError = true }
                    } label: { Text("Перевести").frame(maxWidth: .infinity) }.disabled(recipient.isEmpty || amountText.isEmpty)
                }
            }
            .navigationTitle("Перевод").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Закрыть") { presentationMode.wrappedValue.dismiss() } } }
            .alert("Успешно!", isPresented: $showSuccess) { Button("OK") { presentationMode.wrappedValue.dismiss() } } message: { Text("Перевод выполнен.") }
            .alert("Ошибка", isPresented: $showError) { Button("OK", role: .cancel) {} } message: { Text("Проверьте сумму и баланс.") }
        }
    }
}
