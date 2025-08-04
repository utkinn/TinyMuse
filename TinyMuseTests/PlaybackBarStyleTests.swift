import Testing
import TinyMuse

struct PlaybackBarStyleTests {
    @Test func rawValue() {
        let style = PlaybackBarStyle.waveform
        #expect(style.rawValue == "waveform")
    }
    
    @Test func rawRepresentableInit() {
        let style = PlaybackBarStyle(rawValue: "waveform")
        #expect(style?.id == "waveform")
    }
}
