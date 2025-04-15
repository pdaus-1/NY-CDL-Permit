//
//  MainMenuView.swift
//  NY CDL Permit
//
//  Created by PDA-Jacky on 4/12/25.
//

import SwiftUI

struct MainMenuView: View {
    
    @EnvironmentObject var appState: AppState
    @State private var selectedLanguage = LocalizationManager.shared.currentLanguage
    
    let subjects = [
        "subject_core",
        "subject_air",
        "subject_passenger",
        "subject_schoolbus",
        "subject_combination"
    ]
    
    var body: some View {
        ZStack {
            Image("bj")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                HStack {
                    Spacer()
                    Picker("", selection: $selectedLanguage) {
                        Text("English").tag("en")
                        Text("简体中文").tag("zh-Hans")
                        Text("繁體中文").tag("zh-Hant")
                        Text("Español").tag("es")
                        Text("Русский").tag("ru")
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.trailing)
                    .onChange(of: selectedLanguage) { _, newValue in
                        LocalizationManager.shared.setLanguage(newValue)
                    }
                }
                .padding(.top, 10)
                
                Text(localized("main_menu_title"))
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                
                ForEach(subjects, id: \.self) { subject in
                    NavigationLink(
                        destination: QuizView().environmentObject(appState)
                    ) {
                        Text(localized(subject))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                Text(localized("poweredByPDA"))
                    .font(.footnote)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
            }
        }
        .overlay(alignment: .topLeading) {
            Button(action: {
                appState.isLoggedIn = false
            }) {
                Image(systemName: "arrow.backward.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.leading, 20)
                    .padding(.top, 30)
            }
        }
    }
    
    private func localized(_ key: String) -> String {
        LocalizationManager.shared.localizedString(key)
    }
}

#Preview {
    MainMenuView()
        .environmentObject(AppState())
}
