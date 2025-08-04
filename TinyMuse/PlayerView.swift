import AVFAudio
import SwiftUI

struct PlayerView: View {
    private static let minWindowWidth: CGFloat = 200
    private static let idealWindowWidth: CGFloat = 400
    private static let windowHeight: CGFloat = 50
    
    var fileURL: URL?
    
    @State private var model: AudioPlayerModel
    @AppStorage(SettingsKey.playOnOpen) private var playOnOpen: Bool = SettingsKey.playOnOpenDefault
    
    init(fileURL: URL?) {
        self.fileURL = fileURL
        model = AudioPlayerModel(fileURL: fileURL)
    }
    
    private var showError: Binding<Bool> {
        Binding(
            get: { model.errorText != nil },
            set: { value in model.errorText = value ? model.errorText : nil }
        )
    }
    
    private var windowTitle: String { model.audioName ?? "TinyMuse" }
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            PlayButton(model: $model)
            TimeDisplay(model: $model)
            PlaybackBar(model: $model)
        }
        .padding()
        .frame(
            minWidth: PlayerView.minWindowWidth,
            idealWidth: PlayerView.idealWindowWidth,
            minHeight: PlayerView.windowHeight,
            maxHeight: PlayerView.windowHeight
        )
        .alert(
            "Error",
            isPresented: showError,
            actions: {},
            message: { Text(model.errorText ?? "") }
        )
        .navigationTitle(windowTitle)
        .task {
            await model.load()

            if (playOnOpen) {
                model.play()
            }
        }
        .onAppear {
            if let window = NSApplication.shared.windows.first {
                window.minSize.width = PlayerView.minWindowWidth
                window.minSize.height = PlayerView.windowHeight
                window.maxSize.height = PlayerView.windowHeight
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

struct PlayButton: View {
    @Binding var model: AudioPlayerModel
    
    var body: some View {
        Button("Play", systemImage: model.isPlaying ? "pause.fill" : "play.fill") {
            model.togglePlay()
        }
        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
        .imageScale(.large)
        .font(.title2)
        .frame(width: 24)
    }
}

struct TimeDisplay: View {
    @Binding var model: AudioPlayerModel

    var body: some View {
        let currentTime = formatDuration(seconds: model.currentTime)
        let totalTime = formatDuration(seconds: model.totalTime)
        Text("\(currentTime) / \(totalTime)")
            .fontDesign(.monospaced)
    }
}

struct PlaybackBar: View {
    @Binding var model: AudioPlayerModel
    
    @AppStorage(SettingsKey.playbackBarStyle) private var playbackBarStyle = SettingsKey.playbackBarStyleDefault
    
    var body: some View {
        switch (playbackBarStyle) {
        case .simple:
            Slider(value: $model.progress, onEditingChanged: { editing in
                if !editing {
                    model.setProgress(model.progress)
                }
            })
        case .waveform:
            WaveformSlider(samples: $model.waveformSamples, model: $model, normalized: false)
        case .waveformScaled:
            WaveformSlider(samples: $model.waveformSamples, model: $model, normalized: true)
        default:
            Text("Invalid playback bar style. Please pick a different one in the settings.")
        }
    }
}

fileprivate let packageRootPath = URL(fileURLWithPath: #file)
    .pathComponents
    .dropLast(2)
    .joined(separator: "/")
    .dropFirst()

fileprivate let testAssetsPath = packageRootPath + "/Test Assets"

#Preview {
    PlayerView(fileURL: URL(fileURLWithPath: testAssetsPath + "/1.wav"))
}
