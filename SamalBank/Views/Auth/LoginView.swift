import SwiftUI
struct LoginView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @State private var pin: String = ""
    var body: some View {
        ZStack {
            LinearGradient(colors: [
                Color(.systemIndigo).opacity(0.35),
                Color(.systemBackground)
            ], startPoint: .top, endPoint: .bottom).ignoresSafeArea()

            VStack(spacing: 18) {
                Spacer(minLength: 30)
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 54, weight: .semibold))
                    .foregroundStyle(.primary)
                Text("Samal Bank")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                Text("Введите PIN-код")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)

                HStack(spacing: 14) {
                    ForEach(0..<4, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(index < pin.count ? Color.accentColor : Color(.secondarySystemFill))
                            .frame(width: 18, height: 18)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.tertiaryLabel), lineWidth: index < pin.count ? 0 : 1)
                            )
                    }
                }
                Spacer(minLength: 12)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                    ForEach(1...9, id: \.self) { number in
                        pinButton(String(number))
                    }
                    Color.clear.frame(height: 68)
                    pinButton("0")
                    deleteButton
                }
                .frame(maxWidth: 300)
                .padding(.horizontal)
                Spacer(minLength: 24)
            }
        }
    }

    private func pinButton(_ digit: String) -> some View {
        Button {
            guard pin.count < 4 else { return }
            pin += digit
            if pin.count == 4 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    isLoggedIn = true
                }
            }
        } label: {
            Text(digit)
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity)
                .frame(height: 68)
                .background(.regularMaterial)
                .foregroundStyle(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
    }

    private var deleteButton: some View {
        Button {
            if !pin.isEmpty { pin.removeLast() }
        } label: {
            Image(systemName: "delete.left")
                .font(.title3)
                .frame(maxWidth: .infinity)
                .frame(height: 68)
                .background(.regularMaterial)
                .foregroundStyle(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
    }
}
