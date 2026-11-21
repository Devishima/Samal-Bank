import SwiftUI
struct TransferView: View {
    @EnvironmentObject var store: BankStore
    @Environment(\.presentationMode) var presentationMode
    @State private var recipient = ""
    @State private var amountText = ""
    @State private var note = ""
    @State private var showSuccess = false
    @State private var showError = false
    @State private var transferMode = 0
    @State private var phone = ""
    @State private var cardNumber = ""
    @State private var phoneRecipientName = ""

    private let names = ["Айгуль", "Данияр", "Алия", "Ерасыл", "Аружан", "Диас", "Мадина", "Нурлан"]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 18) {
                    Picker("", selection: $transferMode) {
                        Text("По номеру телефона").tag(0)
                        Text("По номеру карты").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    if transferMode == 0 {
                        phoneFields
                    } else {
                        cardFields
                    }

                    Button {
                        performTransfer()
                    } label: {
                        Text("Перевести")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(canTransfer ? Color.accentColor : Color(.secondarySystemFill))
                            .foregroundStyle(canTransfer ? .white : .secondary)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(!canTransfer)
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .navigationTitle("Перевод").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Закрыть") { presentationMode.wrappedValue.dismiss() } } }
            .alert("Успешно!", isPresented: $showSuccess) { Button("OK") { presentationMode.wrappedValue.dismiss() } } message: { Text("Перевод выполнен.") }
            .alert("Ошибка", isPresented: $showError) { Button("OK", role: .cancel) {} } message: { Text("Проверьте сумму и баланс.") }
        }
    }

    private var phoneFields: some View {
        VStack(spacing: 14) {
            TextField("Номер телефона", text: $phone)
                .keyboardType(.phonePad)
                .multilineTextAlignment(.center)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .onChange(of: phone) { phone = formatPhone($0) }

            if phoneDigits.count == 10 {
                Text("Получатель: \(phoneRecipientName)")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
            }

            TextField("Сумма в тенге", text: $amountText)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            HStack(spacing: 10) {
                ForEach([1000, 5000, 10000], id: \.self) { value in
                    Button("\(value)") { amountText = "\(value)" }
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(.horizontal)

            TextField("Комментарий (необязательно)", text: $note)
                .multilineTextAlignment(.center)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
        }
    }

    private var cardFields: some View {
        VStack(spacing: 14) {
            TextField("Номер карты", text: $cardNumber)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .onChange(of: cardNumber) { cardNumber = formatCard($0) }

            TextField("Сумма в тенге", text: $amountText)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            TextField("Комментарий (необязательно)", text: $note)
                .multilineTextAlignment(.center)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
        }
    }

    private var phoneDigits: String {
        var digits = String(phone.filter(\.isNumber))
        if digits.count > 10, digits.hasPrefix("7") {
            digits.removeFirst()
        }
        return String(digits.prefix(10))
    }

    private var canTransfer: Bool {
        let amountValid = Decimal(string: amountText.replacingOccurrences(of: ",", with: ".")) != nil
        if transferMode == 0 {
            return phoneDigits.count == 10 && amountValid
        }
        return cardNumber.filter(\.isNumber).count == 16 && amountValid
    }

    private func formatPhone(_ text: String) -> String {
        var digits = text.filter(\.isNumber)
        if digits.count > 10, digits.hasPrefix("7") { digits.removeFirst() }
        digits = String(digits.prefix(10))

        if digits.isEmpty { return "" }

        var formatted = "+7"
        if !digits.isEmpty {
            formatted += " " + String(digits.prefix(3))
            let rest = digits.dropFirst(min(3, digits.count))
            if !rest.isEmpty { formatted += " " + String(rest.prefix(3)) }
            let rest2 = rest.dropFirst(min(3, rest.count))
            if !rest2.isEmpty { formatted += " " + String(rest2.prefix(2)) }
            let rest3 = rest2.dropFirst(min(2, rest2.count))
            if !rest3.isEmpty { formatted += " " + rest3.prefix(2) }
        }

        if digits.count == 10 {
            let hash = digits.unicodeScalars.reduce(0) { $0 + Int($1.value) }
            phoneRecipientName = names[hash % names.count]
        } else {
            phoneRecipientName = ""
        }
        return formatted
    }

    private func formatCard(_ text: String) -> String {
        let digits = String(text.filter(\.isNumber).prefix(16))
        return digits.enumerated().map { index, character in
            if index > 0 && index % 4 == 0 { return " \(character)" }
            return String(character)
        }.joined()
    }

    private func performTransfer() {
        guard let amount = Decimal(string: amountText.replacingOccurrences(of: ",", with: ".")) else {
            showError = true
            return
        }
        let recipientName = transferMode == 0
            ? (phoneRecipientName.isEmpty ? phone : phoneRecipientName)
            : String(cardNumber.filter(\.isNumber).suffix(4))
        if store.transfer(to: recipientName, amount: amount, note: note) {
            showSuccess = true
        } else {
            showError = true
        }
    }
}
