import AVFoundation
import Foundation

@MainActor
final class AudioService: ObservableObject {
    private var effectPlayers: [AudioFeedback: AVAudioPlayer] = [:]
    private var musicPlayer: AVAudioPlayer?
    private var isSoundEnabled = true
    private var isMusicEnabled = true

    func update(soundEnabled: Bool, musicEnabled: Bool) {
        isSoundEnabled = soundEnabled
        isMusicEnabled = musicEnabled

        if musicEnabled {
            playBackgroundMusic()
        } else {
            musicPlayer?.stop()
            musicPlayer?.currentTime = 0
        }
    }

    func play(_ feedback: AudioFeedback) {
        guard AudioPlaybackPolicy.shouldPlay(
            feedback,
            isSoundEnabled: isSoundEnabled,
            isMusicEnabled: isMusicEnabled
        ) else {
            return
        }

        if feedback == .backgroundMusic {
            playBackgroundMusic()
        } else {
            playEffect(feedback)
        }
    }

    private func playBackgroundMusic() {
        if let musicPlayer {
            if !musicPlayer.isPlaying {
                musicPlayer.play()
            }
            return
        }

        guard let player = makePlayer(for: .backgroundMusic) else {
            return
        }

        player.numberOfLoops = -1
        player.volume = 0.42
        player.play()
        musicPlayer = player
    }

    private func playEffect(_ feedback: AudioFeedback) {
        let player = effectPlayers[feedback] ?? makePlayer(for: feedback)

        guard let player else {
            return
        }

        effectPlayers[feedback] = player
        player.currentTime = 0
        player.play()
    }

    private func makePlayer(for feedback: AudioFeedback) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(
            forResource: feedback.resourceName,
            withExtension: "wav",
            subdirectory: "GameData/Audio"
        ) else {
            return nil
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            return player
        } catch {
            return nil
        }
    }
}

private extension AudioFeedback {
    var resourceName: String {
        switch self {
        case .backgroundMusic:
            "mansion_loop"
        case .move:
            "move"
        case .blocked:
            "blocked"
        case .undo:
            "undo"
        case .clear:
            "clear"
        }
    }
}
