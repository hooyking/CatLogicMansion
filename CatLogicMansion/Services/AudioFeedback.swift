public enum AudioFeedback: Equatable {
    case backgroundMusic
    case move
    case blocked
    case undo
    case clear

    var isMusic: Bool {
        self == .backgroundMusic
    }
}

public enum AudioPlaybackPolicy {
    public static func shouldPlay(
        _ feedback: AudioFeedback,
        isSoundEnabled: Bool,
        isMusicEnabled: Bool
    ) -> Bool {
        feedback.isMusic ? isMusicEnabled : isSoundEnabled
    }
}
