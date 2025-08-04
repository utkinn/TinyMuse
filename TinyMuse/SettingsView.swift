import SwiftUI

struct SettingsView: View {
    @AppStorage(SettingsKey.playOnOpen) private var playOnOpen = SettingsKey.playOnOpenDefault
    @AppStorage(SettingsKey.singleWindow) private var singleWindow = SettingsKey.singleWindowDefault
    @AppStorage(SettingsKey.quitAfterLastClosedWindow) private var quitAfterLastClosedWindow = SettingsKey.quitAfterLastClosedWindowDefault
    @AppStorage(SettingsKey.playbackBarStyle) private var playbackBarStyle = SettingsKey.playbackBarStyleDefault
    
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

            Picker("Playback bar style", selection: $playbackBarStyle) {
                ForEach(PlaybackBarStyle.allCases) { style in
                    Text("\(style.name) – \(style.description)")
                        .tag(style)
                }
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
