//
//  KeyboardAdaptive.swift
//  NY CDL Permit
//
//  Created by PDA-Jacky on 4/13/25.
//

import SwiftUI
import Combine

struct KeyboardAdaptive: ViewModifier {
    @State private var offset: CGFloat = 0

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .padding(.bottom, offset)
                .onReceive(Publishers.keyboardHeight) { keyboardHeight in
                    let keyboardTop = geometry.frame(in: .global).height - keyboardHeight
                    let focusedTextInputBottom = UIResponder.currentFirstResponder?.globalFrame?.maxY ?? 0
                    self.offset = max(0, focusedTextInputBottom - keyboardTop - 20)
                }
        }
    }
}

extension View {
    func keyboardAdaptive() -> some View {
        self.modifier(KeyboardAdaptive())
    }
}
