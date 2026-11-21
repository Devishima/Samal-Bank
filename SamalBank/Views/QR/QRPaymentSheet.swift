import SwiftUI
struct QRPaymentSheet: View {
    @EnvironmentObject var store: BankStore
    let merchantCode: String
    let onDone: () -> Void
    @State private var amountText = ""
    @State private var showSuccess = false
    @State private var showError = false
    var body: some View {
        VStack(spacing: 20) {
            Capsule().fill(Color.gray.opacity(0.3)).frame(width: 40, height: 5).padding(.top, 8)
            Image(systemName: "checkmark.seal.fill").font(.system(size: 44)).foregroundStyle(.cyan)
            Text("QR распознан").font(.title2.bold())
            Text(merchantCode).font(.caption.monospaced()).foregroundStyle(.secondary).lineLimit(2).multilineTextAlignment(.center).padding(.horizontal)
            TextField("Сумма к оплате", text: $amountText).padding(.horizontal)
            Button {
                if let amount = Decimal(string: amountText.replacingOccurrences(of: ",", with: ".")), store.payQR(merchant: "QR: \(String(merchantCode.prefix(24)))", amount: amount) { showSuccess = true } else { showError = true }
            } label: {
                Text("Оплатить").frame(maxWidth: .infinity).padding().background(amountText.isEmpty ? Color.gray : Color.cyan).foregroundStyle(.black).clipShape(RoundedRectangle(cornerRadius: 14))
            }.disabled(amountText.isEmpty).padding(.horizontal)
            Spacer()
        }.padding()
        .alert("Успешно оплачено ✅", isPresented: $showSuccess) { Button("Готово") { onDone() } } message: { Text("Оплата прошла. Баланс обновлён.") }
        .alert("Ошибка оплаты", isPresented: $showError) { Button("OK", role: .cancel) {} } message: { Text("Недостаточно средств или неверная сумма.") }
    }
}
