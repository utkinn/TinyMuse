import AVFAudio
import SwiftUI

struct ContentView: View {
    var fileURL: URL?
    
    private var player: AVAudioPlayer?
    @State private var errorText: String?
    private var showError: Binding<Bool> {
        Binding(
            get: { errorText != nil },
            set: { value in errorText = value ? errorText : nil }
        )
    }
    
    init(fileURL: URL?) {
        self.fileURL = fileURL
        if let url = fileURL {
            do {
                self.player = try AVAudioPlayer(contentsOf: url)
            } catch let error {
                errorText = error.localizedDescription
            }
        }
    }
    
    private var progress: Binding<Double> {
        Binding(
            get: { player == nil ? 0 : player!.currentTime / player!.duration },
            set: { value in player?.currentTime = value * player!.duration }
        )
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Button("Play", systemImage: "play.fill", action: play)
                .buttonStyle(.plain)
                .labelStyle(.iconOnly)
                .imageScale(.large)
                .font(.title2)
            
            let currentTime = player?.currentTime.description ?? "00:00"
            let totalTime = player?.duration.description ?? "00:00"
            Text("\(currentTime) / \(totalTime)")
            
            Slider(value: progress)
        }
        .padding()
        .frame(
            minWidth: TinyMuseApp.minWindowWidth,
            idealWidth: TinyMuseApp.idealWindowWidth,
            minHeight: TinyMuseApp.windowHeight,
            maxHeight: TinyMuseApp.windowHeight
        )
        .alert(
            "Error",
            isPresented: showError,
            actions: {},
            message: { Text(errorText ?? "") }
        )
    }
    
    func play() {
        
    }
}

#Preview {
    ContentView(fileURL: nil)
}
