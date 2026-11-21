import SwiftUI
struct HomeView: View {
    @EnvironmentObject var store: BankStore
    @State private var showTransfer = false
    @State private var showQR = false
    @State private var showDebug = false
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Добро пожаловать,")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(deviceName)
                            .font(.title2.bold())
                            .foregroundStyle(.primary)
                    }
                    cardView
                    HStack(spacing: 12) {
                        quickButton("Перевод", "arrow.left.arrow.right") { showTransfer = true }
                        quickButton("QR оплата", "qrcode.viewfinder") { showQR = true }
                        quickButton("Пополнить", "plus.circle") { store.addFunds(10_000, reason: "Тестовое пополнение") }
                    }
                    Text("Сервисы")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            serviceTile("Платежи", "creditcard")
                            serviceTile("История", "clock.arrow.circlepath")
                            serviceTile("Кредиты", "banknote")
                            serviceTile("Депозиты", "chart.line.uptrend.xyaxis")
                            serviceTile("Настройки", "gearshape") { showDebug = true }
                        }
                    }
                    Text("Последние операции").font(.headline).foregroundStyle(.primary)
                    VStack(spacing: 0) {
                        ForEach(store.transactions.prefix(5)) { tx in
                            TransactionRow(tx: tx)
                            Divider().background(Color(.separator).opacity(0.25))
                        }
                    }.background(Color(.secondarySystemBackground)).clipShape(RoundedRectangle(cornerRadius: 16))
                }.padding()
            }
            .background(Color(.systemBackground).ignoresSafeArea())
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button { showDebug = true } label: { Image(systemName: "gearshape.fill").foregroundStyle(.primary) }
                }
            }
            .sheet(isPresented: $showTransfer) { TransferView() }
            .sheet(isPresented: $showQR) { QRScannerView() }
            .sheet(isPresented: $showDebug) { DebugMenuView() }
        }
    }
    private var deviceName: String {
        let name = UIDevice.current.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? "Пользователь" : name
    }
    private var cardView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack { Image(systemName: "wave.3.left"); Spacer(); Text("•••• \(store.user.cardNumber)").font(.subheadline.monospaced()) }.foregroundStyle(.white.opacity(0.9))
            Text("Доступно").font(.caption).foregroundStyle(.white.opacity(0.6))
            Text(store.balance, format: .number.precision(.fractionLength(2))).font(.system(size: 36, weight: .bold, design: .rounded)).foregroundStyle(.white).privacySensitive().animation(.easeInOut, value: store.balance)
            Text("KZT").font(.caption).foregroundStyle(.white.opacity(0.6))
        }.padding(20).frame(maxWidth: .infinity, alignment: .leading)
         .background(LinearGradient(colors: [Color(red: 0.0, green: 0.35, blue: 0.55), Color(red: 0.0, green: 0.15, blue: 0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
         .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    private func quickButton(_ title: String, _ icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) { Image(systemName: icon).font(.title2); Text(title).font(.caption) }
            .frame(maxWidth: .infinity).padding(.vertical, 14).background(Color(.secondarySystemBackground)).foregroundStyle(.primary).clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
    private func serviceTile(_ title: String, _ icon: String, action: (() -> Void)? = nil) -> some View {
        Button {
            action?()
        } label: {
            VStack(spacing: 10) {
                Image(systemName: icon).font(.title2)
                Text(title).font(.caption.weight(.semibold)).multilineTextAlignment(.center)
            }
            .foregroundStyle(.primary)
            .frame(width: 92, height: 92)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
    }
}
