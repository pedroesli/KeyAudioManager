# KeyAudioManager

A swift package to make it a lot easier to play audio in your app.

---

# Installation

In Xcode go to `File -> Add Packages... -> Search or Enter Package URL` and paste in the repo's url: https://github.com/pedroesli/KeyAudioManager

## How to use

To be able to play an audio using the KeyAudioManager, you must first provide the audios **file name** and **file extension** using the `add` method 

```swift
let audioManager = KeyAudioManager()

// Add the audios
do {
    try audioManager.addAudio(key: "buttonSound", audioFileName: "Button Sound", fileExtension: "mp3")
    try audioManager.addAudio(key: "song", audioFileName: "Main Menu Song", fileExtension: "mp3")
}
catch{
    print("Error adding audio file: \(error)")
}

// Play an audio using its key
audioManager.play(key: "song")
```

## Useful methods

### play

```swift
audioManager.play(key: "song")

// Or to play an audio after the first one is done playing

audioManager.play(key: "buttonSound"){
        audioManager.play(key: "song")
}
```

### remove

```swift
audioManager.removeAudio(key: "buttonSound")
```

### pause

```swift
audioManager.pause(key: "song")
```

### stop

```swift
audioManager.stop(key: "song")
```

### volume

```swift
// Values ranging from 0.0 for silence to 1.0 for full volume.
audioManager.volume(key: "song", 0.5)
```

### audio Loop

```swift
// repeats and audio indefinitely with a time interval in between the audios 
audioManager.repeatingAudio(key: "song", 2.0)

// To stop repeating audio 
audioManager.stopRepeat()
```

### sequence (Still testing)

```swift
// play a series of audio in a sequence
audioManage.playInSequence("song", "buttonSound", "sound1", "song")
```
