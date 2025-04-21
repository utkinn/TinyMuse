import Foundation
import AVFAudio

class AudioPlayerModel: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var progress: Double = 0.0
    @Published var errorText: String?
    
    private var player: AVAudioPlayer?
    private var timer: Timer?
    
    init(fileURL: URL?) {
        openFile(url: fileURL)
        startTimer()
    }
    
    func openFile(url: URL?) {
        if let url = url {
            do {
                player = try AVAudioPlayer(contentsOf: url)
            } catch {
                errorText = error.localizedDescription
            }
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            guard let player = self.player else { return }
            self.progress = player.duration == 0 ? 0 : player.currentTime / player.duration
        }
    }
    
    func togglePlay() {
        guard let player = player else { return }
        isPlaying.toggle()
        
        if isPlaying {
            player.play()
        } else {
            player.pause()
        }
    }
    
    func setProgress(_ newValue: Double) {
        guard let player = player else { return }
        player.currentTime = newValue * player.duration
        self.progress = newValue
    }
    
    func currentTime() -> TimeInterval? {
        player?.currentTime
    }
    
    func totalTime() -> TimeInterval? {
        player?.duration
    }
}
