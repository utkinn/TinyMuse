import AVFAudio
import SwiftUI

struct PlayerView: View {
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
            Button("Play", systemImage: model.isPlaying ? "pause.fill" : "play.fill") {
                model.togglePlay()
            }
            .buttonStyle(.plain)
            .labelStyle(.iconOnly)
            .imageScale(.large)
            .font(.title2)
            .frame(width: 24)
            
            let currentTime = formatDuration(seconds: model.currentTime())
            let totalTime = formatDuration(seconds: model.totalTime())
            Text("\(currentTime) / \(totalTime)")
                .fontDesign(.monospaced)
            
            Slider(value: $model.progress, onEditingChanged: { editing in
                if !editing {
                    model.setProgress(model.progress)
                }
            })
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
            message: { Text(model.errorText ?? "") }
        )
        .navigationTitle(windowTitle)
        .task {
            if (playOnOpen) {
                model.play()
            }
        }
        .onAppear {
            if let window = NSApplication.shared.windows.first {
                window.minSize.width = TinyMuseApp.minWindowWidth
                window.minSize.height = TinyMuseApp.windowHeight
                window.maxSize.height = TinyMuseApp.windowHeight
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
    PlayerView(fileURL: nil)
}
