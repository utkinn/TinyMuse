import AVFAudio
import SwiftUI

@main
struct TinyMuseApp: App {
    @State private var isOpenDialogOpen = true
    @State private var fileOpenErrorMessage: String = ""
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    
    @State private var openedURLs: [URL] = []
    
    @AppStorage(SettingsKey.singleWindow) private var singleWindow = SettingsKey.singleWindowDefault
    @AppStorage(SettingsKey.quitAfterLastClosedWindow) private var quitAfterLastClosedWindow = SettingsKey.quitAfterLastClosedWindowDefault
    
    private var shouldDisplayFileOpenErrorAlert: Binding<Bool> {
        Binding(
            get: { fileOpenErrorMessage != "" },
            set: { _ in fileOpenErrorMessage = "" }
        )
    }
    
    var body: some Scene {
        WindowGroup(for: URL.self) { $fileUrl in
            if let fileUrl = fileUrl {
                PlayerView(fileURL: fileUrl)
                    .id(fileUrl)
                    .onAppear {
                        if singleWindow {
                            for url in openedURLs {
                                dismissWindow(value: url)
                            }
                        }
                        openedURLs.append(fileUrl)
                    }
                    .onDisappear {
                        openedURLs.removeAll { $0 == fileUrl }
                        fileUrl.stopAccessingSecurityScopedResource()
                        
                        if quitAfterLastClosedWindow && openedURLs.isEmpty {
                            NSApplication.shared.terminate(nil)
                        }
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
        
        Settings {
            SettingsView()
        }
        .windowResizability(.contentSize)
    }
}
