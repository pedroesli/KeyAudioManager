import XCTest
@testable import KeyAudioManager

final class KeyAudioManagerTests: XCTestCase {
    func testNoFile() throws {
        let audioManager = KeyAudioManager()

        XCTAssertNoThrow(try audioManager.addAudio(key: "music", audioFileName: "homeMusic", fileExtension: "mp3"))
        
        audioManager.play(key: "song")
    }
}
