import SwiftUI

@main
struct TinyMuseApp: App {
    static let minWindowWidth: CGFloat = 200
    static let idealWindowWidth: CGFloat = 600
    static let windowHeight: CGFloat = 50
    
    @State private var isOpenDialogOpen = false
    
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
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Open...", action: { isOpenDialogOpen = true })
                    .keyboardShortcut("o")
                    .fileImporter(isPresented: $isOpenDialogOpen, allowedContentTypes: [.audio]) { result in }
            }
            
            // Removes "Edit" menu
            CommandGroup(replacing: .pasteboard) { }
            CommandGroup(replacing: .undoRedo) { }
            CommandGroup(replacing: .textEditing) { }
        }
    }
}
