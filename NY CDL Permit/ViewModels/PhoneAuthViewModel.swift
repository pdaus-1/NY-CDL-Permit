// ===============================
// 📄 2. PhoneAuthViewModel.swift
// ===============================

import Foundation
import FirebaseAuth

@MainActor
class PhoneAuthViewModel: ObservableObject {
    @Published var phoneNumber = ""
    @Published var verificationCode = ""
    @Published var verificationID: String?
    @Published var isCodeSent = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    func sendCode() async {
        isLoading = true
        errorMessage = nil
        let result = await PhoneAuthService.shared.startVerification(phoneNumber: phoneNumber)
        isLoading = false

        switch result {
        case .success(let id):
            self.verificationID = id
            self.isCodeSent = true
        case .failure(let error):
            self.errorMessage = error.localizedDescription
        }
    }

    func verifyCodeAndSignIn(appState: AppState) async {
        guard let id = verificationID else {
            errorMessage = "Missing verification ID"
            return
        }
        isLoading = true
        let result = await PhoneAuthService.shared.signIn(verificationID: id, verificationCode: verificationCode)
        isLoading = false

        switch result {
        case .success:
            appState.isLoggedIn = true
            appState.phoneNumber = phoneNumber
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
}

