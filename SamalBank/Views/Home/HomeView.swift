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
                    cardView
                    HStack(spacing: 12) {
                        quickButton("Перевод", "arrow.left.arrow.right") { showTransfer = true }
                        quickButton("QR оплата", "qrcode.viewfinder") { showQR = true }
                        quickButton("Пополнить", "plus.circle") { store.addFunds(10_000, reason: "Тестовое пополнение") }
                    }
                    Text("Последние операции").font(.headline).foregroundStyle(.white)
                    VStack(spacing: 0) {
                        ForEach(store.transactions.prefix(5)) { tx in
                            TransactionRow(tx: tx)
                            Divider().background(Color.white.opacity(0.05))
                        }
                    }.background(Color.white.opacity(0.05)).clipShape(RoundedRectangle(cornerRadius: 16))
                }.padding()
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Samal Bank")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button { showDebug = true } label: { Image(systemName: "gearshape.fill").foregroundStyle(.white) }
                }
            }
            .sheet(isPresented: $showTransfer) { TransferView() }
            .sheet(isPresented: $showQR) { QRScannerView() }
            .sheet(isPresented: $showDebug) { DebugMenuView() }
        }
    }
    private var cardView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack { Image(systemName: "wave.3.left"); Text("Samal Bank").font(.headline); Spacer(); Text("•••• \(store.user.cardNumber)").font(.subheadline.monospaced()) }.foregroundStyle(.white.opacity(0.9))
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
            .frame(maxWidth: .infinity).padding(.vertical, 14).background(Color.white.opacity(0.08)).foregroundStyle(.white).clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}
