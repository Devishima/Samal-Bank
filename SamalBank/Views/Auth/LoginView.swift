import SwiftUI
struct LoginView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @State private var pin: String = ""
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.0, green: 0.15, blue: 0.35), .black], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack(spacing: 24) {
                Spacer()
                Image(systemName: "building.columns.fill").font(.system(size: 64)).foregroundStyle(.white)
                Text("Samal Bank").font(.largeTitle.bold()).foregroundStyle(.white)
                Spacer()
                VStack(spacing: 12) {
                    SecureField("Введите PIN (любой)", text: $pin).textFieldStyle(.roundedBorder).multilineTextAlignment(.center).padding(.horizontal, 32)
                    Button { isLoggedIn = true } label: {
                        Text("Войти").frame(maxWidth: .infinity).padding().background(Color.white).foregroundStyle(.black).clipShape(RoundedRectangle(cornerRadius: 14))
                    }.padding(.horizontal, 32)
                }
                Text("Демо-режим · без реальных денег").font(.footnote).foregroundStyle(.white.opacity(0.6))
                Spacer()
            }
        }
    }
}
