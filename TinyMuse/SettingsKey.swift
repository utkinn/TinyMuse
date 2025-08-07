import Foundation

struct SettingsKey {
    static let playOnOpen = "playOnOpen"
    static let playOnOpenDefault = true
    
    static let singleWindow = "singleWindow"
    static let singleWindowDefault = false
    
    static let quitAfterLastClosedWindow = "quitAfterLastClosedWindow"
    static let quitAfterLastClosedWindowDefault = false
    
    static let playbackBarStyle = "playbackBarStyle"
    static let playbackBarStyleDefault = PlaybackBarStyle.waveformScaled
    
    static let keyboardArrowJumpDuration = "keyboardArrowJumpDuration"
    static let keyboardArrowJumpDurationDefault: TimeInterval = 15
}

public struct PlaybackBarStyle: RawRepresentable, Identifiable, Hashable {
    public static let simple = PlaybackBarStyle(id: "simple", name: String(localized: "Simple"), description: String(localized: "Simple slider"))
    public static let waveform = PlaybackBarStyle(id: "waveform", name: String(localized: "Waveform"), description: String(localized: "Shows the audio waveform with amplitude representing the real volume"))
    public static let waveformScaled = PlaybackBarStyle(id: "waveformScaled", name: String(localized: "Waveform (scaled)"), description: String(localized: "Shows the audio waveform scaled to fit the available height"))
    
    public static let allCases = [simple, waveform, waveformScaled]

    public var rawValue: String { id }
    public var id: String
    public var name: String
    public var description: String
    
    public init?(rawValue: String) {
        for style in PlaybackBarStyle.allCases {
            if style.id == rawValue {
                self.init(id: style.id, name: style.name, description: style.description)
                return
            }
        }
        
        return nil
    }
    
    public init(id: String, name: String, description: String) {
        self.id = id
        self.name = name
        self.description = description
    }
}
