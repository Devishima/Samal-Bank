import SwiftUI

struct TransferView: View {
    @EnvironmentObject var store: BankStore
    @Environment(\.presentationMode) var presentationMode

    @State private var mode = 0
    @State private var phone = ""
    @State private var cardNumber = ""
    @State private var amountText = ""
    @State private var note = ""
    @State private var recipientName = ""
    @State private var showSuccess = false
    @State private var showError = false

    private let names = ["Айгуль", "Данияр", "Алия", "Ерасыл", "Аружан", "Диас", "Мадина", "Нурлан"]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 18) {
                    Picker("", selection: $mode) {
                        Text("Телефон").tag(0)
                        Text("Карта").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    if mode == 0 {
                        phoneFields
                    } else {
                        cardFields
                    }

                    TextField("Комментарий", text: $note)
                        .multilineTextAlignment(.center)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)

                    Button {
                        performTransfer()
                    } label: {
                        Text("Перевести")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(canTransfer ? Color.blue : Color(.secondarySystemFill))
                            .foregroundStyle(canTransfer ? Color.white : Color.secondary)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(!canTransfer)
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .navigationTitle("Перевод")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .alert("Успешно!", isPresented: $showSuccess) {
                Button("OK") {
                    presentationMode.wrappedValue.dismiss()
                }
            } message: {
                Text("Перевод выполнен.")
            }
            .alert("Ошибка", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Проверьте сумму и баланс.")
            }
        }
    }

    private var phoneFields: some View {
        VStack(spacing: 14) {
            TextField("+7 ", text: $phone)
                .keyboardType(.phonePad)
                .multilineTextAlignment(.center)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .onChange(of: phone) { value in
                    phone = formatPhone(value)
                }

            if phoneDigits.count >= 10 {
                Text("Получатель: \(recipientName)")
                    .font(.subheadline.bold())
                    .foregroundStyle(.green)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.green.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
            }

            amountField
        }
    }

    private var cardFields: some View {
        VStack(spacing: 14) {
            TextField("Номер карты (16 цифр)", text: $cardNumber)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .onChange(of: cardNumber) { value in
                    cardNumber = formatCard(value)
                }

            amountField
        }
    }

    private var amountField: some View {
        VStack(spacing: 12) {
            TextField("Сумма в тенге", text: $amountText)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            HStack(spacing: 10) {
                ForEach([1000, 5000, 10000], id: \.self) { value in
                    Button("\(value)") {
                        amountText = "\(value)"
                    }
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color(.secondarySystemBackground))
                    .foregroundStyle(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(.horizontal)
        }
    }

    private var phoneDigits: String {
        var digits = phone.filter(\.isNumber)
        if digits.count > 10, digits.hasPrefix("7") {
            digits.removeFirst()
        }
        return String(digits.prefix(10))
    }

    private var canTransfer: Bool {
        let amount = Decimal(string: amountText.replacingOccurrences(of: ",", with: "."))
        guard let amount, amount > 0 else { return false }

        if mode == 0 {
            return phoneDigits.count >= 10
        }
        return cardNumber.filter(\.isNumber).count == 16
    }

    private func formatPhone(_ value: String) -> String {
        var digits = value.filter(\.isNumber)
        if digits.count > 10, digits.hasPrefix("7") {
            digits.removeFirst()
        }
        digits = String(digits.prefix(10))

        guard !digits.isEmpty else { return "" }

        var result = "+7"
        if !digits.isEmpty {
            result += " " + String(digits.prefix(3))
        }
        let firstRest = digits.dropFirst(min(3, digits.count))
        if !firstRest.isEmpty {
            result += " " + String(firstRest.prefix(3))
        }
        let secondRest = firstRest.dropFirst(min(3, firstRest.count))
        if !secondRest.isEmpty {
            result += " " + String(secondRest.prefix(2))
        }
        let lastRest = secondRest.dropFirst(min(2, secondRest.count))
        if !lastRest.isEmpty {
            result += " " + String(lastRest.prefix(2))
        }

        if digits.count >= 10 {
            let hash = digits.unicodeScalars.reduce(0) { $0 + Int($1.value) }
            recipientName = names[hash % names.count]
        } else {
            recipientName = ""
        }
        return result
    }

    private func formatCard(_ value: String) -> String {
        let digits = String(value.filter(\.isNumber).prefix(16))
        return digits.enumerated().map { index, character in
            index > 0 && index % 4 == 0 ? " \(character)" : String(character)
        }.joined()
    }

    private func performTransfer() {
        guard let amount = Decimal(string: amountText.replacingOccurrences(of: ",", with: ".")) else {
            showError = true
            return
        }

        let recipient = mode == 0
            ? (recipientName.isEmpty ? phone : recipientName)
            : String(cardNumber.filter(\.isNumber).suffix(4))

        if store.transfer(to: recipient, amount: amount, note: note) {
            showSuccess = true
        } else {
            showError = true
        }
    }
}
