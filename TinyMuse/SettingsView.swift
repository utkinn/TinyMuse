import SwiftUI

struct SettingsView: View {
    @Binding var playOnOpen: Bool
    
    var body: some View {
        HStack {
            Toggle(isOn: $playOnOpen) {
                Text("Start playing after opening a file")
            }
        }
        .padding()
    }
}

#Preview {
    SettingsView(playOnOpen: Binding.constant(true))
}
