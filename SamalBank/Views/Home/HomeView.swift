import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: BankStore
    @State private var showTransfer = false
    @State private var showQR = false
    @State private var showHistory = false
    @State private var showPayments = false

    private var deviceName: String {
        let name = UIDevice.current.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? "Пользователь" : name
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Добро пожаловать,")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(deviceName)
                            .font(.title2.bold())
                            .foregroundStyle(.primary)
                    }

                    balanceCard

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            serviceTile(title: "Перевод", icon: "arrow.left.arrow.right") {
                                showTransfer = true
                            }
                            serviceTile(title: "QR-оплата", icon: "qrcode.viewfinder") {
                                showQR = true
                            }
                            serviceTile(title: "Платежи", icon: "creditcard") {
                                showPayments = true
                            }
                            serviceTile(title: "История", icon: "clock.arrow.circlepath") {
                                showHistory = true
                            }
                            serviceTile(title: "Кредиты", icon: "banknote")
                        }
                    }

                    Text("Последние операции")
                        .font(.headline)
                        .foregroundStyle(.primary)

                    VStack(spacing: 0) {
                        ForEach(store.transactions.prefix(5)) { transaction in
                            TransactionRow(tx: transaction)
                            Divider()
                                .background(Color(.separator).opacity(0.25))
                        }
                    }
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding()
            }
            .background(Color(.systemBackground).ignoresSafeArea())
            .navigationBarHidden(true)
            .sheet(isPresented: $showTransfer) { TransferView() }
            .sheet(isPresented: $showQR) { QRScannerView() }
            .sheet(isPresented: $showHistory) { HistoryView() }
            .sheet(isPresented: $showPayments) { PaymentsView() }
        }
    }

    private var balanceCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "wave.3.left")
                Spacer()
                Text("•••• \(store.user.cardNumber)")
                    .font(.subheadline.monospaced())
            }
            .foregroundStyle(.white.opacity(0.9))

            Text("Доступно")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))

            Text(store.balance, format: .number.precision(.fractionLength(2)))
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .animation(.easeInOut, value: store.balance)

            Text("KZT")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.0, green: 0.35, blue: 0.55),
                    Color(red: 0.0, green: 0.15, blue: 0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func serviceTile(
        title: String,
        icon: String,
        action: (() -> Void)? = nil
    ) -> some View {
        Button {
            action?()
        } label: {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption.weight(.semibold))
                    .multilineTextAlignment(.center)
            }
            .foregroundStyle(.primary)
            .frame(width: 94, height: 94)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
    }
}
