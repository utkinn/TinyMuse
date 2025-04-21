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
    @State private var isPlaying: Bool = false
    
    init(fileURL: URL?) {
        self.fileURL = fileURL
        if let url = fileURL {
            do {
                player = try AVAudioPlayer(contentsOf: url)
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
            Button("Play", systemImage: isPlaying ? "pause.fill" : "play.fill") {
                isPlaying.toggle()
            }
            .buttonStyle(.plain)
            .labelStyle(.iconOnly)
            .imageScale(.large)
            .font(.title2)
            
            let currentTime = formatDuration(seconds: player?.currentTime)
            let totalTime = formatDuration(seconds: player?.duration)
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
        .onChange(of: isPlaying) {
            old, new in
            if new {
                player?.play()
            } else {
                player?.pause()
            }
        }
    }
}

func formatDuration(seconds: TimeInterval?) -> String {
    guard let seconds = seconds else { return "--:--" }

    let minutes = seconds.rounded(.down) / 60
    let secondsPart = seconds.truncatingRemainder(dividingBy: 60)
    return String(format: "%02d:%02d", Int(minutes), Int(secondsPart))
}

#Preview {
    ContentView(fileURL: nil)
}
