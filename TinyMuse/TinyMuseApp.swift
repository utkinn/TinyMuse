import AVFAudio
import SwiftUI

@main
struct TinyMuseApp: App {
    static let minWindowWidth: CGFloat = 200
    static let idealWindowWidth: CGFloat = 400
    static let windowHeight: CGFloat = 50
    
    @State private var isOpenDialogOpen = true
    @State private var fileOpenErrorMessage: String = ""
    
    @Environment(\.openWindow) private var openWindow
    
    @AppStorage("playOnOpen") private var playOnOpen: Bool = true
    
    private var shouldDisplayFileOpenErrorAlert: Binding<Bool> {
        Binding(
            get: { fileOpenErrorMessage != "" },
            set: { _ in fileOpenErrorMessage = "" }
        )
    }
    
    var body: some Scene {
        WindowGroup(for: URL.self) { $fileUrl in
            if let fileUrl = fileUrl {
                ContentView(fileURL: fileUrl, playOnOpen: playOnOpen)
                    .id(fileUrl)
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
                    .onDisappear {
                        fileUrl.stopAccessingSecurityScopedResource()
                    }
            } else {
                EmptyView()
                    .onOpenURL {
                        isOpenDialogOpen = false
                        openWindow(value: $0)
                    }
            }
        }
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("Settings...", action: { openWindow(id: "settings") })
                    .keyboardShortcut(",")
            }
            
            CommandGroup(replacing: .newItem) {
                Button("Open...", action: { isOpenDialogOpen = true })
                    .keyboardShortcut("o")
                    .fileImporter(isPresented: $isOpenDialogOpen, allowedContentTypes: [.audio]) {
                        result in
                        switch result {
                        case .success(let url):
                            openWindow(value: url)
                        case .failure(let error):
                            fileOpenErrorMessage = error.localizedDescription
                        }
                    }
                    .alert("File open error", isPresented: shouldDisplayFileOpenErrorAlert, actions: {}, message: { Text(fileOpenErrorMessage) })
            }
            
            // Removes "Edit" menu
            CommandGroup(replacing: .pasteboard) { }
            CommandGroup(replacing: .undoRedo) { }
            CommandGroup(replacing: .textEditing) { }
        }
        
        WindowGroup(id: "settings") {
            SettingsView(playOnOpen: $playOnOpen)
        }
    }
}
