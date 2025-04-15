//
//  UIResponder+FirstResponder.swift
//  NY CDL Permit
//
//  Created by PDA-Jacky on 4/13/25.
//

import UIKit

extension UIResponder {
    private struct Static {
        static weak var responder: UIResponder?
    }

    static var currentFirstResponder: UIResponder? {
        Static.responder = nil
        UIApplication.shared.sendAction(#selector(_trap), to: nil, from: nil, for: nil)
        return Static.responder
    }

    @objc private func _trap() {
        Static.responder = self
    }

    var globalFrame: CGRect? {
        guard let view = self as? UIView else { return nil }
        return view.superview?.convert(view.frame, to: nil)
    }
}
