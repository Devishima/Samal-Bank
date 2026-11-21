import SwiftUI

struct PaymentsView: View {
    @EnvironmentObject var store: BankStore
    @Environment(\.presentationMode) var presentationMode

    private let services = [
        ("Мобильная связь", "phone.fill"),
        ("Коммунальные услуги", "house.fill"),
        ("Интернет", "wifi")
    ]

    var body: some View {
        NavigationView {
            List {
                ForEach(services, id: \.0) { service in
                    NavigationLink(destination: PaymentDetailView(serviceName: service.0)) {
                        Label(service.0, systemImage: service.1)
                            .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Платежи")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct PaymentDetailView: View {
    @EnvironmentObject var store: BankStore
    @Environment(\.presentationMode) var presentationMode

    let serviceName: String
    @State private var amountText = ""
    @State private var showSuccess = false
    @State private var showError = false

    var body: some View {
        VStack(spacing: 18) {
            Spacer()

            Image(systemName: "creditcard.fill")
                .font(.system(size: 48))
                .foregroundStyle(.blue)

            Text(serviceName)
                .font(.title3.bold())
                .multilineTextAlignment(.center)

            TextField("Сумма в тенге", text: $amountText)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            Button {
                guard let amount = Decimal(string: amountText.replacingOccurrences(of: ",", with: ".")),
                      store.transfer(to: serviceName, amount: amount, note: "Оплата услуги") else {
                    showError = true
                    return
                }
                showSuccess = true
            } label: {
                Text("Оплатить")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(amountText.isEmpty ? Color(.secondarySystemFill) : Color.blue)
                    .foregroundStyle(amountText.isEmpty ? .secondary : .white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(amountText.isEmpty)
            .padding(.horizontal)

            Spacer()
        }
        .navigationTitle(serviceName)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Успешно!", isPresented: $showSuccess) {
            Button("OK") {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Оплата выполнена.")
        }
        .alert("Ошибка", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Проверьте сумму и баланс.")
        }
    }
}
