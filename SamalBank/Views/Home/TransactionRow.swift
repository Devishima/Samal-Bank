import SwiftUI
struct TransactionRow: View {
    let tx: Transaction
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName).font(.system(size: 18, weight: .semibold)).frame(width: 40, height: 40).background(color.opacity(0.2)).foregroundStyle(color).clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(tx.title).font(.subheadline).foregroundStyle(.white)
                Text(tx.date, format: .dateTime.day().month().hour().minute()).font(.caption2).foregroundStyle(.white.opacity(0.5))
            }
            Spacer()
            Text((tx.kind == .incoming ? "+" : "−") + formatted(tx.amount)).font(.subheadline.monospacedDigit()).foregroundStyle(tx.kind == .incoming ? .green : .white)
        }.padding(.horizontal, 14).padding(.vertical, 10)
    }
    private var iconName: String {
        switch tx.kind { case .incoming: return "arrow.down.left"; case .outgoing: return "cart.fill"; case .qr: return "qrcode"; case .transfer: return "arrow.left.arrow.right" }
    }
    private var color: Color {
        switch tx.kind { case .incoming: return .green; case .outgoing: return .orange; case .qr: return .cyan; case .transfer: return .blue }
    }
    private func formatted(_ amount: Decimal) -> String {
        let f = NumberFormatter(); f.numberStyle = .decimal; f.minimumFractionDigits = 2; f.maximumFractionDigits = 2
        return f.string(from: amount as NSDecimalNumber) ?? "\(amount)"
    }
}
