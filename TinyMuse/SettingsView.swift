import SwiftUI

struct SettingsView: View {
    @AppStorage(SettingsKey.playOnOpen) private var playOnOpen = SettingsKey.playOnOpenDefault
    @AppStorage(SettingsKey.singleWindow) private var singleWindow = SettingsKey.singleWindowDefault
    @AppStorage(SettingsKey.quitAfterLastClosedWindow) private var quitAfterLastClosedWindow = SettingsKey.quitAfterLastClosedWindowDefault
    
    var body: some View {
        VStack(alignment: .leading) {
            Toggle(isOn: $playOnOpen) { Text("Start playing after opening a file") }
            Toggle(isOn: $singleWindow) {
                Text("Single window only")
                Text("On opening a new file, the existing window will be reused.")
            }
            Toggle(isOn: $quitAfterLastClosedWindow) {
                Text("Quit after last closed window")
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
