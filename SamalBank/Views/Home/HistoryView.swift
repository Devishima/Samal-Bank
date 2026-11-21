import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var store: BankStore
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List {
                ForEach(store.transactions) { transaction in
                    TransactionRow(tx: transaction)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color(.systemBackground))
                }
            }
            .listStyle(.plain)
            .navigationTitle("История")
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
