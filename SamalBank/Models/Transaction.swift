import Foundation
struct Transaction: Identifiable, Codable, Equatable {
    enum Kind: String, Codable { case incoming, outgoing, qr, transfer }
    let id: UUID
    let title: String
    let amount: Decimal
    let kind: Kind
    let date: Date
    init(id: UUID = UUID(), title: String, amount: Decimal, kind: Kind, date: Date = Date()) {
        self.id = id; self.title = title; self.amount = amount; self.kind = kind; self.date = date
    }
}
