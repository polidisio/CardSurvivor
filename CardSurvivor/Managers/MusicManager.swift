import AVFoundation

// MARK: - Music Manager
class MusicManager: ObservableObject {
    static let shared = MusicManager()
    
    private var audioPlayer: AVAudioPlayer?
    private var soundEffects: [String: AVAudioPlayer] = [:]
    private var isMuted: Bool = false
    
    @Published var currentTrack: String = ""
    @Published var isPlaying: Bool = false
    
    // Track names (without extension)
    let tracks: [String: String] = [
        "menu": "01_Menu_Gothic",
        "exploration": "02_Exploration",
        "exploration2": "03_Exploration_2",
        "castle": "04_Castle",
        "combat": "05_Combat",
        "boss": "06_Boss",
        "cave": "07_Cave",
        "village": "08_Village"
    ]
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    // MARK: - Play Music
    
    func play(track: String, loop: Bool = true) {
        guard !isMuted else { return }
        
        // Stop current music
        stop()
        
        let trackName = tracks[track] ?? track
        
        // Try different extensions
        let extensions = ["mp3", "m4a", "wav", "ogg"]
        
        for ext in extensions {
            if let url = Bundle.main.url(forResource: trackName, withExtension: ext) {
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer?.numberOfLoops = loop ? -1 : 0
                    audioPlayer?.volume = 0.7
                    audioPlayer?.prepareToPlay()
                    audioPlayer?.play()
                    currentTrack = trackName
                    isPlaying = true
                    print("Playing: \(trackName).\(ext)")
                    return
                } catch {
                    print("Error playing \(trackName): \(error)")
                }
            }
        }
        
        print("Music file not found: \(trackName)")
    }
    
    func playMenu() {
        play(track: "menu")
    }
    
    func playCombat() {
        play(track: "combat")
    }
    
    func playBoss() {
        play(track: "boss")
    }
    
    func playExploration() {
        play(track: "exploration")
    }
    
    func playVillage() {
        play(track: "village")
    }
    
    func playCave() {
        play(track: "cave")
    }
    
    // MARK: - Stop/Pause
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
    }
    
    func pause() {
        audioPlayer?.pause()
        isPlaying = false
    }
    
    func resume() {
        audioPlayer?.play()
        isPlaying = true
    }
    
    // MARK: - Volume Control
    
    func setVolume(_ volume: Float) {
        audioPlayer?.volume = max(0, min(1, volume))
    }
    
    func fadeOut(duration: TimeInterval = 1.0) {
        guard let player = audioPlayer else { return }
        
        let steps = 20
        let interval = duration / Double(steps)
        let volumeStep = player.volume / Float(steps)
        
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            if player.volume > volumeStep {
                player.volume -= volumeStep
            } else {
                timer.invalidate()
                self.stop()
                player.volume = 0.7 // Reset for next play
            }
        }
    }
    
    // MARK: - Mute
    
    func toggleMute() {
        isMuted.toggle()
        if isMuted {
            audioPlayer?.pause()
            isPlaying = false
        } else {
            audioPlayer?.play()
            isPlaying = true
        }
    }
    
    // MARK: - Sound Effects
    
    func playSoundEffect(named name: String) {
        guard !isMuted else { return }
        
        let extensions = ["mp3", "m4a", "wav", "ogg", "caf"]
        
        for ext in extensions {
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.volume = 1.0
                    player.play()
                    soundEffects[name] = player
                    return
                } catch {
                    print("Error playing sound \(name): \(error)")
                }
            }
        }
        
        print("Sound effect not found: \(name)")
    }
}

// MARK: - Game Sound Effects
extension MusicManager {
    // Card sounds
    func playCardDraw() {
        playSoundEffect(named: "card_draw")
    }
    
    func playCardPlay() {
        playSoundEffect(named: "card_play")
    }
    
    // Combat sounds
    func playAttack() {
        playSoundEffect(named: "attack")
    }
    
    func playBlock() {
        playSoundEffect(named: "block")
    }
    
    func playEnemyDeath() {
        playSoundEffect(named: "enemy_death")
    }
    
    func playPlayerHurt() {
        playSoundEffect(named: "player_hurt")
    }
    
    // UI sounds
    func playButtonClick() {
        playSoundEffect(named: "button_click")
    }
    
    func playLevelUp() {
        playSoundEffect(named: "level_up")
    }
    
    func playVictory() {
        playSoundEffect(named: "victory")
    }
    
    func playDefeat() {
        playSoundEffect(named: "defeat")
    }
}

// MARK: - Usage Examples
/*
 // In your game:
 
 // Play menu music when app starts
 MusicManager.shared.playMenu()
 
 // Change to combat music when battle starts
 MusicManager.shared.fadeOut()
 MusicManager.shared.playCombat()
 
 // Play boss music
 MusicManager.shared.playBoss()
 
 // Sound effects
 MusicManager.shared.playAttack()
 MusicManager.shared.playCardDraw()
 MusicManager.shared.playLevelUp()
 
 // Mute toggle
 MusicManager.shared.toggleMute()
*/
