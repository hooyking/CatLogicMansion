import Testing
@testable import CatLogicMansionCore

@Suite("AudioFeedback")
struct AudioFeedbackTests {
    @Test("sound effects follow sound setting")
    func soundEffectsFollowSoundSetting() {
        #expect(AudioPlaybackPolicy.shouldPlay(.move, isSoundEnabled: true, isMusicEnabled: false))
        #expect(!AudioPlaybackPolicy.shouldPlay(.move, isSoundEnabled: false, isMusicEnabled: true))
    }

    @Test("music follows music setting")
    func musicFollowsMusicSetting() {
        #expect(AudioPlaybackPolicy.shouldPlay(.backgroundMusic, isSoundEnabled: false, isMusicEnabled: true))
        #expect(!AudioPlaybackPolicy.shouldPlay(.backgroundMusic, isSoundEnabled: true, isMusicEnabled: false))
    }
}
