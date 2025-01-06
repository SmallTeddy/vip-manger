//
//  vip_managerApp.swift
//  vip-manager
//
//  Created by SmallTeddy on 2025/1/6.
//

import SwiftUI

@main
struct vip_managerApp: App {
    init() {
        #if os(macOS)
        // 禁用状态恢复
        UserDefaults.standard.set(false, forKey: "NSQuitAlwaysKeepsWindows")
        UserDefaults.standard.set(true, forKey: "ApplePersistenceIgnoreState")
        // 禁用自动保存
        UserDefaults.standard.set(false, forKey: "NSCloseAlwaysConfirmsChanges")
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        #if os(macOS)
        .windowResizability(.contentSize)
        .defaultSize(width: 800, height: 600)
        .commands {
            CommandGroup(replacing: .saveItem) { }
            CommandGroup(replacing: .undoRedo) { }
            CommandGroup(replacing: .pasteboard) { }
        }
        .defaultPosition(.center)
        .windowStyle(.automatic)
        #endif
    }
}
