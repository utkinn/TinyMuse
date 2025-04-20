//
//  TinyMuseApp.swift
//  TinyMuse
//
//  Created by Nikita Utkin on 2025/04/20.
//

import SwiftUI

@main
struct TinyMuseApp: App {
    static let minWindowWidth: CGFloat = 200
    static let idealWindowWidth: CGFloat = 600
    static let windowHeight: CGFloat = 50
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(
                    GeometryReader { _ in
                        Color.clear
                            .onAppear {
                                if let window = NSApplication.shared.windows.first {
                                    window.minSize.width = TinyMuseApp.minWindowWidth
                                    window.minSize.height = TinyMuseApp.windowHeight
                                    window.maxSize.height = TinyMuseApp.windowHeight
                                }
                            }
                    }
                )
        }
        .windowResizability(.contentSize)
    }
}
