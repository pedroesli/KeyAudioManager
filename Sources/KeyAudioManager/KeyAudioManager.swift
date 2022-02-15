//
//  KeyAudioManager.swift
//  Mini03
//
//  Created by Pedro Ésli Vieira do Nascimento on 09/02/22.
//

import AVKit

/**
    A class that makes it easier to play audios based on key reference.
 
    Use the `addAudio()` function to register a audio, then use `play()` function to start the audio.
 */
public class KeyAudioManager {
    
    private class AudioPlayerManagerDelegate: NSObject, AVAudioPlayerDelegate{
        
        var doneAction: (() -> Void)?
        
        func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
            if flag {
                doneAction?()
            }
        }
    }
    
    /// Erros that may happen when adding an audio to the list.
    public enum AudioError: Error {
        case noFileLocated(String)
        case couldNotLoadAudioFile(String)
    }
    
    private var audioPlayers: [String:AVAudioPlayer] = [:]
    private var keySequence: [String] = []
    private var audioSequenceDelegate = AudioPlayerManagerDelegate()
    private var singleAudioDelegate = AudioPlayerManagerDelegate()
    private var stopRepeatingAudio = false
    
    /// Returns the number of audios contained in the list
    public var audioListSize: Int {
        return audioPlayers.count
    }
    
    /**
        Adds an audio to the manager audio list
     
        - Parameters:
            - key: a unique key for this audio (if key already exists, it will update that adio player)
            - audioFileName: The name of the audio file
            - fileExtension: The file extension of the file (ex: mp3, wav...). If `fileExtension` is an empty string or nil, the extension is assumed not to exist and the file URL is the first file encountered that exactly matches name.
     
        - Throws: **noFileLocated** in case the specified file could not be found or **couldNotLoadAudioFile** if the file is not an readable audio file
     */
    public func addAudio(key: String, audioFileName: String, fileExtension: String? = nil) throws {
        //Load a local sound file
        guard let soundFileURL = Bundle.main.url(forResource: audioFileName, withExtension: fileExtension) else { throw AudioError.noFileLocated(audioFileName) }
        
        do {
            let player = try AVAudioPlayer(contentsOf: soundFileURL)
            //player.prepareToPlay()
            audioPlayers[key] = player
        }
        catch {
            throw AudioError.couldNotLoadAudioFile(audioFileName)
        }
    }
    
    /**
        Adds an audio to the manager audio list based on the `AudioInformation` provided
     
        - Parameter audioInformation: The information of the audio file
        
        - Throws: **noFileLocated** in case the specified file could not be found or **couldNotLoadAudioFile** if the file is not an readable audio file
     */
    public func addAudio(audioInformation: AudioInformation) throws {
        try addAudio(key: audioInformation.key, audioFileName: audioInformation.fileName, fileExtension: audioInformation.fileExtension)
    }
    
    /**
        Remove an audio from the audio list
     
        - Parameter key: The key of the audio to remove
     */
    public func removeAudio(key: String){
        audioPlayers.removeValue(forKey: key)
    }
    
    /**
        Starts playing an audio or resume and audio that was paused
     
        - Parameter key: The key of the audio to play or resume
     */
    public func play(key: String) {
        audioPlayers[key]?.play()
    }
    
    /**
        Starts playing an audio or resume and audio that was paused. And calls the `doneAction` after the audio is done playing
     
        - Parameters:
            - key: The key of the audio to play or resume
            - doneAction: Is called after the audio is done playing
     */
    public func play(key: String, doneAction: @escaping () -> Void ) {
        audioPlayers[key]?.delegate = singleAudioDelegate
        play(key: key)
        singleAudioDelegate.doneAction = {
            doneAction()
        }
    }
    
    /**
        Plays audio asynchronously, starting at a specified point in the audio output device’s timeline.

         - Parameters:
             - key: The key of the audio to play or resume.
             - time: The audio device time to begin playback. This time must be later than the device’s current time.
     */
    public func play(key: String, atTime time: TimeInterval){
        audioPlayers[key]?.play(atTime: time)
    }
    
    
    /**
        Plays audio asynchronously, starting at a specified point in the audio output device’s timeline.

         - Parameters:
             - key: The key of the audio to play or resume.
             - time: The audio device time to begin playback. This time must be later than the device’s current time.
             - doneAction: Is called after the audio is done playing.
     */
    public func play(key: String, atTime time: TimeInterval, doneAction: @escaping () -> Void) {
        audioPlayers[key]?.delegate = singleAudioDelegate
        play(key: key, atTime: time)
        
        singleAudioDelegate.doneAction = {
            doneAction()
        }
    }
    
    /**
        Pause an audio thats playing. Unlike calling `stop()`, pausing playback doesn’t deallocate hardware resources. It leaves the audio ready to resume playback from where it stops.
     
        - Parameter key: The key of the audio to pause
     */
    public func pause(key: String) {
        audioPlayers[key]?.pause()
    }
    
    /**
        Stop an audio thats playing
     
        - Parameter key: The key of the audio to stop
     */
    public func stop(key: String) {
        audioPlayers[key]?.stop()
    }
    
    /// Stops all audio that is playing
    public func stopAll(){
        audioPlayers.forEach { (_, audioPlayer) in
            if audioPlayer.isPlaying {
                audioPlayer.stop()
            }
        }
    }
    
    /**
        Sets the volume of a choosen audio
     
        - Parameters:
            - key: The key of audio
            - value: The new value of the volume. This parameter supports values ranging from **0.0** for silence to **1.0** for full volume.
     */
    public func volume(key: String, _ value: Float) {
        audioPlayers[key]?.volume = value
    }
    
    /**
        Repeats a selected audio with a wait interval in between the audios
     
        - Parameters:
            - key: They key of audio
            - timeInterval: The time in second for the repeater to wait before playing the next song
     */
    public func repeatingAudio(key: String, timeInterval: TimeInterval) {
        if !stopRepeatingAudio {
            play(key: key) {
                Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false, block: { timer in
                    self.repeatingAudio(key: key, timeInterval: timeInterval)
                })
            }
        }
        else{
            stopRepeatingAudio = false
        }
    }
    
    /// Stops the repeating audio. (Does not stop the audio if its playing)
    public func stopRepeat() {
        stopRepeatingAudio = true
    }
    
    /**
        Plays a list of audio one after the other. Tip: The songs need to be added to the list using `addAudio()`
     
        - Parameter keys: A list of audio keys to played in sequence
     
        - Example: a simple play sequence
            \
            ```
            manager.playInSequence(["audio2", "audio1", "audio4"])
            ```
     */
    public func playInSequence(keys: [String]){
        keySequence = keys
        playFirstOfKeySequence()
    }
    
    ///Plays the first audio from the `keySequence` the plays the rest of the audio until theres no sequence left (uses the player delegate to play the next audio)
    private func playFirstOfKeySequence(){
        guard let firstKey = keySequence.first, let player = audioPlayers[firstKey] else { return }
        player.delegate = audioSequenceDelegate
        player.play()
        keySequence.removeFirst()
        audioSequenceDelegate.doneAction = {
            self.playFirstOfKeySequence()
        }
    }
}
