import AVFAudio
import SwiftUI

@main
struct TinyMuseApp: App {
    static let minWindowWidth: CGFloat = 200
    static let idealWindowWidth: CGFloat = 600
    static let windowHeight: CGFloat = 50
    
    @State private var isOpenDialogOpen = false
    @State private var currentFileURL: URL? = nil
    @State private var fileOpenErrorMessage: String = ""
    private var shouldDisplayFileOpenErrorAlert: Binding<Bool> {
        Binding(
            get: { fileOpenErrorMessage != "" },
            set: { _ in fileOpenErrorMessage = "" }
        )
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(fileURL: currentFileURL)
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
                    .fileImporter(isPresented: $isOpenDialogOpen, allowedContentTypes: [.audio]) {
                        result in
                        switch result {
                        case .success(let url):
                            if url != currentFileURL {
                                currentFileURL?.stopAccessingSecurityScopedResource()
                            }
                            currentFileURL = url
                            let accessStartSuccess = url.startAccessingSecurityScopedResource()
                            if !accessStartSuccess {
                                fileOpenErrorMessage = "Failed to acquire access to the file."
                            }
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
    }
}
