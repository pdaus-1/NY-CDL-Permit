// ===============================
// 📦 1. PhoneAuthService.swift
// ===============================

import Foundation
import FirebaseAuth

enum PhoneAuthError: Error, LocalizedError {
    case emptyPhoneNumber
    case invalidVerificationCode
    case tooManyRequests
    case userDisabled
    case networkError
    case invalidPhoneNumber
    case appCheckFailed
    case unknownError

    var errorDescription: String? {
        switch self {
        case .emptyPhoneNumber: return NSLocalizedString("emptyPhoneNumber", comment: "")
        case .invalidVerificationCode: return NSLocalizedString("invalidVerificationCode", comment: "")
        case .tooManyRequests: return NSLocalizedString("tooManyRequests", comment: "")
        case .userDisabled: return NSLocalizedString("userDisabled", comment: "")
        case .networkError: return NSLocalizedString("networkError", comment: "")
        case .invalidPhoneNumber: return NSLocalizedString("invalidPhoneNumber", comment: "")
        case .appCheckFailed: return NSLocalizedString("appCheckFailed", comment: "")
        case .unknownError: return NSLocalizedString("unknownError", comment: "")
        }
    }
}

class PhoneAuthService {
    static let shared = PhoneAuthService()
    private init() {}

    func startVerification(
        phoneNumber: String,
        uiDelegate: AuthUIDelegate? = nil,
        multiFactorSession: MultiFactorSession? = nil
    ) async -> Result<String, Error> {
        guard !phoneNumber.isEmpty else {
            return .failure(PhoneAuthError.emptyPhoneNumber)
        }
        
        let cleaned = phoneNumber.filter("0123456789".contains)
        let formatted = "+1\(cleaned)"

        do {
            let verificationID = try await PhoneAuthProvider.provider().verifyPhoneNumber(
                formatted,
                uiDelegate: uiDelegate,
                multiFactorSession: multiFactorSession
            )
            print("✅ verificationID returned: \(verificationID)")
            return .success(verificationID)
        } catch let error as NSError {
            print("❌ Firebase verification error: \(error.localizedDescription)")
            return .failure(mapFirebaseError(error))
        }
    }

    func signIn(
        verificationID: String,
        verificationCode: String
    ) async -> Result<AuthDataResult, Error> {
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verificationCode
        )
        do {
            let result = try await Auth.auth().signIn(with: credential)
            return .success(result)
        } catch let error as NSError {
            return .failure(mapFirebaseError(error))
        }
    }

    private func mapFirebaseError(_ error: NSError) -> PhoneAuthError {
        switch error.code {
        case AuthErrorCode.invalidVerificationCode.rawValue: return .invalidVerificationCode
        case AuthErrorCode.tooManyRequests.rawValue: return .tooManyRequests
        case AuthErrorCode.networkError.rawValue: return .networkError
        case AuthErrorCode.userDisabled.rawValue: return .userDisabled
        case AuthErrorCode.invalidPhoneNumber.rawValue: return .invalidPhoneNumber
        case 17028: return .appCheckFailed
        default:
            print("⚠️ Unmapped Firebase error: \(error.localizedDescription)")
            return .unknownError
        }
    }
}

