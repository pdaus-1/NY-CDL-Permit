//
//  ContentView.swift
//  NY CDL Permit
//
//  Created by PDA-Jacky on 4/12/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    // 自动提取数据，并按时间戳排序（最新首先）
    @Query(sort: \Item.timestamp, order: .reverse) private var items: [Item]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        // 导航到详情页面
                        ItemDetailView(item: item)
                    } label: {
                        Text(item.timestamp, format: .dateTime.year().month().day().hour().minute())
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Items List")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Please select an item")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
        }
    }

    // 添加新项到数据环境中，使用当前时间戳
    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    // 删除选中的数据条目
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.forEach { index in
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
