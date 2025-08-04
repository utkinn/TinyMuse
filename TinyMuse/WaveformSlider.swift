import SwiftUI

struct WaveformSlider: View {
    @Binding var samples: [Float]
    @Binding var model: AudioPlayerModel
    var normalized: Bool = false

    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let width = geometry.size.width
            
            ZStack {
                Canvas { context, size in
                    let barWidth = size.width / CGFloat(samples.count)
                    let midY = size.height / 2
                    let normalizationFactor: Float = normalized ? (samples.max() ?? 1) : 1

                    for (index, sample) in samples.enumerated() {
                        let x = CGFloat(index) * barWidth
                        let barHeight = normalizationFactor > 0 ? (CGFloat(sample) / CGFloat(normalizationFactor)) * size.height : 0
                        let y = midY - barHeight / 2
                        let rect = CGRect(x: x, y: y, width: barWidth, height: barHeight)
                        context.fill(Path(rect), with: .color(.primary))
                    }
                }

                Capsule()
                    .frame(width: 2, height: height)
                    .foregroundColor(.blue)
                    .position(x: width * model.progress, y: height / 2)
            }
            .background(.regularMaterial)
            .onTapGesture { location in
                model.setProgress(Double(location.x) / Double(geometry.size.width))
            }
        }
    }
}

#Preview("Not normalized") {
    WaveformSlider(samples: .constant([0.1, 0.2, 0.4, 0.3, 0.4, 0.1]), model: .constant(AudioPlayerModel(fileURL: nil)), normalized: false)
        .frame(height: 60)
}

#Preview("Normalized") {
    WaveformSlider(samples: .constant([0.1, 0.2, 0.4, 0.3, 0.4, 0.1]), model: .constant(AudioPlayerModel(fileURL: nil)), normalized: true)
        .frame(height: 60)
}
