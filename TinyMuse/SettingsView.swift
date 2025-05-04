import SwiftUI

struct SettingsView: View {
    @AppStorage(SettingsKey.playOnOpen) private var playOnOpen: Bool = SettingsKey.playOnOpenDefault
    
    var body: some View {
        HStack {
            Toggle(isOn: $playOnOpen) {
                Text("Start playing after opening a file")
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
