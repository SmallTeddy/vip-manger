//
//  ContentView.swift
//  vip-manager
//
//  Created by SmallTeddy on 2025/1/6.
//

import SwiftUI
#if os(iOS)
import UIKit
#else
import AppKit
#endif

struct ContentView: View {
    @StateObject private var store = MemberStore()
    @State private var showingAddMember = false
    @State private var memberToDelete: Member?
    @State private var searchText = ""
    @State private var columns = [
        GridItem(.adaptive(minimum: 300, maximum: 400), spacing: 16)
    ]
    
    var filteredMembers: [Member] {
        if searchText.isEmpty {
            return store.members
        } else {
            return store.members.filter { member in
                member.storeName.localizedCaseInsensitiveContains(searchText) ||
                member.location.localizedCaseInsensitiveContains(searchText) ||
                member.phoneNumber.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // 提取删除警告框为单独的视图
    private var deleteAlert: Alert {
        Alert(
            title: Text("确认删除"),
            message: Text("确定要删除这个会员吗？此操作不可撤销。"),
            primaryButton: .destructive(Text("删除")) {
                deleteSelectedMember()
            },
            secondaryButton: .cancel(Text("取消")) {
                memberToDelete = nil
            }
        )
    }
    
    // 提取工具栏内容
    @ToolbarContentBuilder
    private var toolbarButtons: some ToolbarContent {
        #if os(iOS)
        ToolbarItem(placement: .navigationBarTrailing) {
            layoutMenu
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            addButton
        }
        #else
        ToolbarItem {
            layoutMenu
        }
        ToolbarItem {
            addButton
        }
        #endif
    }
    
    // 布局菜单
    private var layoutMenu: some View {
        Menu {
            Button(action: { columns = [GridItem(.flexible())] }) {
                Label("单列", systemImage: "rectangle.grid.1x2")
            }
            Button(action: { setTwoColumns() }) {
                Label("双列", systemImage: "rectangle.grid.2x2")
            }
        } label: {
            Image(systemName: "rectangle.grid.2x2")
        }
    }
    
    // 添加按钮
    private var addButton: some View {
        Button(action: { showingAddMember = true }) {
            Image(systemName: "plus")
        }
    }
    
    // 单个会员卡片视图
    private func memberCardView(for member: Member) -> some View {
        MemberCard(store: store, member: member) {
            memberToDelete = member
        }
        .background {
            #if os(iOS)
            Color(uiColor: .systemBackground)
            #else
            Color(nsColor: .textBackgroundColor)
            #endif
        }
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // 会员卡片网格内容
    private var gridContent: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(filteredMembers) { member in
                memberCardView(for: member)
            }
        }
        .padding(16)
    }
    
    // 会员卡片网格
    private var memberGrid: some View {
        ScrollView {
            gridContent
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            #if os(iOS)
            Color(uiColor: .systemGroupedBackground)
            #else
            Color(nsColor: .windowBackgroundColor)
            #endif
        }
    }
    
    var body: some View {
        NavigationStack {
            memberGrid
                .searchable(text: $searchText, prompt: "搜索会员")
                .navigationTitle("会员管理")
                .toolbar { toolbarButtons }
                .sheet(isPresented: $showingAddMember) {
                    AddMemberView(store: store)
                        #if os(macOS)
                        .frame(minWidth: 400, minHeight: 450)
                        #endif
                }
                .alert(
                    "确认删除",
                    isPresented: .constant(memberToDelete != nil),
                    presenting: memberToDelete
                ) { _ in
                    Button("取消", role: .cancel) {
                        memberToDelete = nil
                    }
                    Button("删除", role: .destructive) {
                        deleteSelectedMember()
                    }
                } message: { _ in
                    Text("确定要删除这个会员吗？此操作不可撤销。")
                }
        }
        .task {
            try? await store.load()
        }
        #if os(macOS)
        .frame(minWidth: 800, minHeight: 600)
        #endif
    }
    
    // MARK: - Helper Methods
    
    private func setTwoColumns() {
        columns = [
            GridItem(.adaptive(minimum: 300, maximum: 400), spacing: 16)
        ]
    }
    
    private func deleteSelectedMember() {
        if let member = memberToDelete {
            store.deleteMember(member)
            memberToDelete = nil
        }
    }
}

#Preview {
    ContentView()
}
