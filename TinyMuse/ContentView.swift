import SwiftUI

struct ContentView: View {
    @State private var progress: Double = 0
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Button("Play", systemImage: "play.fill", action: play)
                .buttonStyle(.plain)
                .labelStyle(.iconOnly)
                .imageScale(.large)
                .font(.title2)
            
            Text("00:00")
            
            Slider(value: $progress)
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
    ContentView()
}
