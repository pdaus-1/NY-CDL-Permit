//
//  Item.swift
//  NY CDL Permit
//
//  Created by PDA-Jacky on 4/12/25.
//

import Foundation
import SwiftData

@Model
public final class Item {
    public var timestamp: Date

    public init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
