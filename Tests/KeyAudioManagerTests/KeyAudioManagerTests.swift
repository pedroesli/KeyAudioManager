import XCTest
@testable import KeyAudioManager

final class KeyAudioManagerTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        //XCTAssertEqual(KeyAudioManager().text, "Hello, World!")
        let audioManager = KeyAudioManager()
        do {
            try audioManager.addAudio(key: "buttonSound", audioFileName: "Button Sound", fileExtension: "mp3")
            try audioManager.addAudio(key: "song", audioFileName: "Main Menu Song", fileExtension: "mp3")
        }
        catch{
            print("Error adding audio file: \(error)")
        }
        
        audioManager.play(key: "song")
    }
}
