import Foundation
import Combine

final class BankStore: ObservableObject {
    @Published var user: User
    @Published var balance: Decimal
    @Published var transactions: [Transaction]

    init() {
        self.user = User(name: "Samal User", cardNumber: "4400", phone: "+7 700 000 00 00")
        self.balance = 125_000.00
        self.transactions = [
            Transaction(title: "Пополнение", amount: 50_000, kind: .incoming, date: Date().addingTimeInterval(-86400 * 2)),
            Transaction(title: "Coffee Point", amount: 1_800, kind: .qr, date: Date().addingTimeInterval(-3600 * 5)),
            Transaction(title: "Перевод Айгуль", amount: 15_000, kind: .transfer, date: Date().addingTimeInterval(-86400)),
            Transaction(title: "Супермаркет", amount: 8_450, kind: .outgoing, date: Date().addingTimeInterval(-86400 * 3))
        ]
    }
    func addFunds(_ amount: Decimal, reason: String = "Тестовое пополнение") {
        balance += amount
        transactions.insert(Transaction(title: reason, amount: amount, kind: .incoming), at: 0)
    }
    func transfer(to recipient: String, amount: Decimal, note: String) -> Bool {
        guard amount > 0, balance >= amount else { return false }
        balance -= amount
        let title = note.isEmpty ? "Перевод: \(recipient)" : "Перевод: \(recipient) — \(note)"
        transactions.insert(Transaction(title: title, amount: amount, kind: .transfer), at: 0)
        return true
    }
    func payQR(merchant: String, amount: Decimal) -> Bool {
        guard amount > 0, balance >= amount else { return false }
        balance -= amount
        transactions.insert(Transaction(title: merchant, amount: amount, kind: .qr), at: 0)
        return true
    }
    func reset() {
        balance = 125_000.00
        transactions = [
            Transaction(title: "Пополнение", amount: 50_000, kind: .incoming, date: Date().addingTimeInterval(-86400 * 2)),
            Transaction(title: "Coffee Point", amount: 1_800, kind: .qr, date: Date().addingTimeInterval(-3600 * 5)),
            Transaction(title: "Перевод Айгуль", amount: 15_000, kind: .transfer, date: Date().addingTimeInterval(-86400)),
            Transaction(title: "Супермаркет", amount: 8_450, kind: .outgoing, date: Date().addingTimeInterval(-86400 * 3))
        ]
    }
}
