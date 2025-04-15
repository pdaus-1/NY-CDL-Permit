//
//  ItemDetailView.swift
//  NY CDL Permit
//
//  Created by PDA-Jacky on 4/12/25.
//

import SwiftUI
import SwiftData

struct ItemDetailView: View {
    let item: Item

    var body: some View {
        VStack(spacing: 15) {
            Text("Item Information")
                .font(.title)
                .bold()

            Text("Timestamp:")
                .font(.caption)
                .foregroundColor(.secondary)

            // Fixed date & time format issue
            Text(item.timestamp, format: .dateTime.year().month().day().hour().minute())
                .multilineTextAlignment(.center)
                .padding()

            Spacer()
        }
        .padding()
        .navigationBarTitle("Details", displayMode: .inline)
    }
}

#Preview {
    let previewItem = Item(timestamp: Date())
    return NavigationStack {
        ItemDetailView(item: previewItem)
    }
}
