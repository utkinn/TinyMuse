import AVFAudio
import SwiftUI

struct ContentView: View {
    var fileURL: URL?
    
    private var player: AVAudioPlayer?

    init(fileURL: URL?) {
        self.fileURL = fileURL
        if let url = fileURL {
            self.player = try? AVAudioPlayer(contentsOf: url)
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
    }
    
    func play() {
        
    }
}

#Preview {
    ContentView(fileURL: nil)
}
