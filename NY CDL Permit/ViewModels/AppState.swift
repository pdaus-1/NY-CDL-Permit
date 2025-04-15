//
//  AppState.swift
//  NY CDL Permit
//
//  Created by PDA-Jacky on 4/12/25.
//
import SwiftUI
import Foundation

final class AppState: ObservableObject {
    
    @Published var isLoggedIn = false
    @Published var phoneNumber: String = ""
    @Published var prefix: String = "A-"
    @Published var selectedCategory: String? = nil
    @Published var quizQuestions: [QuizQuestion] = []
    @Published var score: Int = 0
    @Published var passed: Bool = false
}
