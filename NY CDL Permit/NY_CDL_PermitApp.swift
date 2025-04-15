//
//  NY_CDL_PermitApp.swift
//  NY CDL Permit
//
//  Created by PDA-Jacky on 4/12/25.
//

import SwiftUI

@main
struct NY_CDL_PermitApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate  
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if appState.isLoggedIn {
                    MainMenuView().environmentObject(appState)
                } else {
                    LoginView_v4().environmentObject(appState)
                }
            }
        }
    }
}
