import Foundation
import AVFAudio
import AVFoundation
import SwiftUI

@Observable
class AudioPlayerModel {
    var isPlaying: Bool = false
    var progress: Double = 0.0
    var errorText: String?
    var waveformSamples: [Float] = []
    
    private var fileURL: URL?
    private var player: AVAudioPlayer?
    @ObservationIgnored private lazy var audioPlayerObserver: AudioPlayerObserver = AudioPlayerObserver(owner: self)
    
    @ObservationIgnored private var timer: Timer?
    
    init(fileURL: URL?) {
        self.fileURL = fileURL
        openFile(url: fileURL)
        startTimer()
    }
    
    func load() async {
        if let url = fileURL {
            waveformSamples = (try? await loadWaveformSamples(from: url, samplesCount: 1000)) ?? []
        }
    }
    
    var isFileOpened: Bool { player != nil }
    var audioName: String? { player?.url?.lastPathComponent }
    
    func openFile(url: URL?) {
        if let url = url {
            guard url.startAccessingSecurityScopedResource() else {
                errorText = "Can't start accessing the file security scoped resource."
                return
            }

            do {
                player = try AVAudioPlayer(contentsOf: url)
                if let player = player {
                    player.delegate = audioPlayerObserver
                    guard player.prepareToPlay() else {
                        errorText = "Can't prepare to play the file."
                        return
                    }
                }
            } catch {
                errorText = error.localizedDescription
            }
        }
    }
    
    deinit {
        timer?.invalidate()
        player?.stop()
        player?.url?.stopAccessingSecurityScopedResource()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self else { return }
            guard let player = self.player else { return }
            self.progress = player.duration == 0 ? 0 : player.currentTime / player.duration
            self.currentTime = player.currentTime
            self.totalTime = player.duration
        }
    }
    
    func play() {
        guard let player = player else { return }
        isPlaying = true
        player.play()
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
    
    var currentTime: TimeInterval?
    var totalTime: TimeInterval?
    
    class AudioPlayerObserver: NSObject, AVAudioPlayerDelegate {
        private weak var owner: AudioPlayerModel?
        
        init(owner: AudioPlayerModel) {
            self.owner = owner
        }
        
        func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
            owner?.isPlaying = false
        }
    }
    
    private func loadWaveformSamples(from url: URL, samplesCount: Int) async throws -> [Float]? {
        let asset = AVURLAsset(url: url)
        guard let track = try await asset.loadTracks(withMediaType: .audio).first else { return nil }
        
        let readerSettings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMBitDepthKey: 16
        ]
        
        let readerOutput = AVAssetReaderTrackOutput(track: track, outputSettings: readerSettings)
        
        guard let reader = try? AVAssetReader(asset: asset) else { return nil }
        reader.add(readerOutput)
        
        reader.startReading()
        
        var waveformSamples = [Float]()
        
        while let sampleBuffer = readerOutput.copyNextSampleBuffer(),
              let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) {
            
            let length = CMBlockBufferGetDataLength(blockBuffer)
            var data = Data(count: length)
            try data.withUnsafeMutableBytes { buffer in
                let result = CMBlockBufferCopyDataBytes(blockBuffer, atOffset: 0, dataLength: length, destination: buffer.baseAddress!)
                if result != kCMBlockBufferNoErr {
                    throw WaveformSampleError.bufferCopyError
                }
            }
            
            let samples = data.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) in
                let ptr = buffer.bindMemory(to: Int16.self)
                return Array(ptr)
            }
            
            // Downsample: Group samples into chunks and take the RMS (root mean square) or max amplitude
            let samplesPerBin = max(1, samples.count / samplesCount)
            for i in stride(from: 0, to: samples.count, by: samplesPerBin) {
                let chunk = samples[i..<min(i+samplesPerBin, samples.count)]
                let maxAmp = chunk.map { abs(Float($0)) }.max() ?? 0
                waveformSamples.append(maxAmp / Float(Int16.max))  // Normalize to 0...1
            }
            
            CMSampleBufferInvalidate(sampleBuffer)
        }
        
        return waveformSamples
    }
}

enum WaveformSampleError: Error {
    case bufferCopyError
}
