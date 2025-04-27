import SwiftUI

struct SettingsView: View {
    @Binding var playOnOpen: Bool
    
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
    SettingsView(playOnOpen: Binding.constant(true))
}
