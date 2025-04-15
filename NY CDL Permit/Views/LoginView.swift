import SwiftUI
import FirebaseAuth
import AVFoundation

struct LoginView_v4: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = PhoneAuthViewModel()
    @State private var selectedPrefix = "A-"
    @State private var selectedLanguage = LocalizationManager.shared.currentLanguage

    private let prefixOptions = ["A-", "BP-", "BPS-"]

    var body: some View {
        GeometryReader { geo in
            let screenWidth = geo.size.width

            ZStack {
                Image("sm")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .blur(radius: 3)

                ScrollView {
                    VStack(spacing: 14) {
                        // 顶部按钮组
                        HStack {
                            Button(action: {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                appState.isLoggedIn = false
                            }) {
                                Image(systemName: "arrowshape.turn.up.backward.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(Color.black.opacity(0.4))
                                    .clipShape(Circle())
                            }

                            Spacer()

                            Menu {
                                Picker("", selection: $selectedLanguage) {
                                    Text("English").tag("en")
                                    Text("简体中文").tag("zh-Hans")
                                    Text("繁體中文").tag("zh-Hant")
                                    Text("Español").tag("es")
                                    Text("Русский").tag("ru")
                                }
                                .onChange(of: selectedLanguage) { _, lang in
                                    LocalizationManager.shared.setLanguage(lang)
                                }
                            } label: {
                                Image(systemName: "globe")
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(Color.black.opacity(0.4))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                        Spacer(minLength: 10)

                        // 标题
                        Text("🚌 NY CDL Permit 🚛")
                            .font(.system(size: screenWidth * 0.065, weight: .bold))
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(10)

                        // Prefix Picker
                        Picker("", selection: $selectedPrefix) {
                            ForEach(prefixOptions, id: \.self) { option in
                                Text(option).font(.system(size: screenWidth * 0.045))
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: screenWidth * 0.7)

                        // 手机输入框
                        TextField(NSLocalizedString("enterPhone", comment: ""), text: $viewModel.phoneNumber)
                            .keyboardType(.numberPad)
                            .padding(10)
                            .frame(width: screenWidth * 0.65)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(6)

                        // 发验证码按钮
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            AudioServicesPlaySystemSound(1104)
                            Task { await viewModel.sendCode() }
                        }) {
                            HStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                }
                                Text(viewModel.isLoading ? "Sending..." : NSLocalizedString("sendCode", comment: ""))
                                    .font(.system(size: screenWidth * 0.045, weight: .semibold))
                            }
                            .frame(width: screenWidth * 0.5)
                            .padding(.vertical, 10)
                            .background(viewModel.isLoading ? Color.gray : Color.blue.opacity(0.85))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .shadow(radius: 5)
                        }
                        .disabled(viewModel.isLoading)

                        // 验证码输入区
                        if viewModel.isCodeSent {
                            TextField(NSLocalizedString("enterCode", comment: ""), text: $viewModel.verificationCode)
                                .keyboardType(.numberPad)
                                .padding(10)
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(6)
                                .frame(width: screenWidth * 0.5)

                            Button(action: {
                                Task { await viewModel.verifyCodeAndSignIn(appState: appState) }
                            }) {
                                Text(NSLocalizedString("confirm", comment: ""))
                                    .font(.system(size: screenWidth * 0.045))
                                    .frame(width: screenWidth * 0.4)
                                    .padding(.vertical, 8)
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(6)
                            }
                        }

                        // 错误提示
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.system(size: screenWidth * 0.035))
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }

                        // 联系信息 + QR + Logo
                        VStack(spacing: 6) {
                            Image("qrcode")
                                .resizable()
                                .frame(width: 100, height: 100)

                            HStack(spacing: 10) {
                                Image("js_logo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 24)
                                Image("pda_logo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 24)
                            }

                            Text("📞 718-205-6789 / 718-899-1166")
                                .font(.footnote)
                                .foregroundColor(.white)

                            Link("🌐 www.jsdrivingschool.com", destination: URL(string: "https://www.jsdrivingschool.com")!)
                                .font(.footnote)
                                .foregroundColor(.white)
                        }

                        Spacer(minLength: 16)

                        Text("⚠️ J&S/PDA 教學專用 App ⚠️")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.85))
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 8)
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                }
            }
        }
    }
}
