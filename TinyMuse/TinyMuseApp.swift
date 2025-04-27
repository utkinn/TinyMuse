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
