import SwiftUI

struct SettingsView: View {
    @AppStorage(SettingsKey.playOnOpen) private var playOnOpen: Bool = SettingsKey.playOnOpenDefault
    @AppStorage(SettingsKey.singleWindow) private var singleWindow: Bool = SettingsKey.singleWindowDefault
    
    var body: some View {
        VStack(alignment: .leading) {
            Toggle(isOn: $playOnOpen) { Text("Start playing after opening a file") }
            Toggle(isOn: $singleWindow) {
                Text("Single window only")
                Text("On opening a new file, the existing window will be reused.")
            }
        }
        .navigationTitle("Settings")
        .padding()
        .windowResizeBehavior(.disabled)
    }
}

#Preview {
    SettingsView()
}
