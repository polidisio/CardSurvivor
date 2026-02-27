import Foundation

// MARK: - Game State
enum GameState {
    case classSelection
    case menu
    case profile  // NEW: Profile/Relics screen
    case playing
    case playerTurn
    case enemyTurn
    case shop
    case relicShop  // NEW: Buy relics
    case waveComplete
    case gameOver
}

// MARK: - Game Model
class GameModel: ObservableObject {
    @Published var state: GameState = .classSelection
    @Published var player: Player = Player()
    @Published var enemies: [Enemy] = []
    @Published var wave: Int = 1
    @Published var score: Int = 0
    @Published var selectedCard: Card?
    @Published var selectedEnemy: Enemy?
    @Published var message: String = ""
    @Published var showMessage: Bool = false
    @Published var playerBlock: Int = 0
    @Published var enemyBlock: Int = 0
    @Published var gemsEarned: Int = 0  // Show at end of run
    
    var progression: PlayerProgression = PlayerProgression.current
    var availableRelics: [Relic] = []
    var gameWon: Bool = false
    
    var highScore: Int {
        get { UserDefaults.standard.integer(forKey: "highScore") }
        set { UserDefaults.standard.set(newValue, forKey: "highScore") }
    }
    
    var shopCards: [Card] = []
    
    func selectClass(_ playerClass: PlayerClass) {
        guard progression.unlockedClasses.contains(playerClass) else { return }
        player = Player(playerClass: playerClass)
        state = .menu
    }
    
    func startNewGame() {
        enemies = Enemy.generate(for: 1)
        generateEnemyIntents()
        wave = 1
        score = 0
        playerBlock = 0
        enemyBlock = 0
        gameWon = false
        player.startTurn()
        state = .playerTurn
    }
    
    func startNextWave() {
        wave += 1
        enemies = Enemy.generate(for: wave)
        generateEnemyIntents()
        playerBlock = 0
        enemyBlock = 0
        player.startTurn()
        state = .playerTurn
    }
    
    func generateEnemyIntents() {
        for i in enemies.indices {
            enemies[i].generateIntent(playerHP: player.hp, playerBlock: playerBlock, otherEnemiesCount: enemies.count - 1)
        }
    }
    
    func selectCard(_ card: Card) {
        guard state == .playerTurn else { return }
        let discount = (player.playerClass == .mage && card.type == .power) ? 1 : 0
        
        if card.type == .attack {
            if selectedCard?.id == card.id {
                selectedCard = nil
            } else {
                selectedCard = card
            }
        } else {
            playCard(card, targetIndex: nil, energyDiscount: discount)
        }
    }
    
    func selectEnemy(_ enemy: Enemy) {
        guard state == .playerTurn, let card = selectedCard, card.type == .attack else { return }
        
        if let index = enemies.firstIndex(where: { $0.id == enemy.id }) {
            let discount = (player.playerClass == .mage && card.type == .power) ? 1 : 0
            playCard(card, targetIndex: index, energyDiscount: discount)
        }
    }
    
    func playCard(_ card: Card, targetIndex: Int?, energyDiscount: Int = 0) {
        guard state == .playerTurn else { return }
        
        let actualCost = max(0, card.cost - energyDiscount)
        guard player.energy >= actualCost else {
            showTemporaryMessage("⚡ No tienes energía!")
            return
        }
        
        player.energy -= actualCost
        
        if let index = player.hand.firstIndex(where: { $0.id == card.id }) {
            player.hand.remove(at: index)
            player.discardPile.append(card)
        }
        
        switch card.type {
        case .attack:
            guard let idx = targetIndex else {
                showTemporaryMessage("🎯 Selecciona un enemigo!")
                return
            }
            
            let damage = card.value + player.damageBuff
            let actualDamage = enemies[idx].takeDamage(damage)
            
            if player.lifestealPercent > 0 && Int.random(in: 1...100) <= player.lifestealPercent {
                let lifesteal = max(1, actualDamage / 4)
                player.heal(lifesteal)
                showTemporaryMessage("⚔️ \(actualDamage) dmg! +❤️\(lifesteal)")
            } else {
                showTemporaryMessage("⚔️ \(actualDamage) dmg!")
            }
            
            if enemies[idx].isDead {
                let goldReward = enemies[idx].type == .boss ? 50 : (enemies[idx].isElite ? 20 : 5) + wave
                let expReward = enemies[idx].type == .boss ? 50 : (enemies[idx].isElite ? 25 : 10)
                
                score += enemies[idx].type == .boss ? 100 : (enemies[idx].isElite ? 30 : 10)
                player.addGold(goldReward)
                player.addExperience(expReward)
                
                enemies.remove(at: idx)
                showTemporaryMessage("💀 +\(goldReward) gold! +\(expReward) XP")
            }
            
        case .defense:
            playerBlock += card.value + player.relicBonusBlock
            showTemporaryMessage("🛡️ +\(card.value) bloqueo!")
            
        case .power:
            applyPowerCard(card)
            
        case .draw:
            player.drawCards(card.value)
            showTemporaryMessage("📚 +\(card.value) cartas!")
            
        case .special:
            applySpecialCard(card, targetIndex: targetIndex)
        }
        
        selectedCard = nil
        checkTurnEnd()
    }
    
    func applyPowerCard(_ card: Card) {
        if card.name.contains("Veneno") || card.nameEn.contains("Poison") {
            if !enemies.isEmpty {
                enemies[0].applyPoison(card.value, turns: 3)
                showTemporaryMessage("☠️ Veneno!")
            }
        } else if card.name.contains("Furia") || card.nameEn.contains("Rage") || card.name.contains("Aura") {
            player.damageBuff += card.value
            player.damageBuffTurns = card.name.contains("Aura") ? 2 : 3
            showTemporaryMessage("⚔️ +\(card.value) dmg!")
        } else if card.name.contains("Curación") || card.nameEn.contains("Heal") || card.name.contains("Regeneración") {
            player.heal(card.value)
            showTemporaryMessage("❤️ +\(card.value) HP!")
        }
    }
    
    func applySpecialCard(_ card: Card, targetIndex: Int?) {
        if card.name.contains("Apocalipsis") || card.nameEn.contains("Apocalypse") {
            for i in enemies.indices {
                _ = enemies[i].takeDamage(5)
            }
            showTemporaryMessage("💥 Daño a todos!")
            enemies.removeAll { $0.isDead }
        } else if card.name.contains("Dragon") || card.nameEn.contains("Dragon") {
            if let idx = targetIndex {
                _ = enemies[idx].takeDamage(card.value)
                if enemies[idx].isDead {
                    enemies.remove(at: idx)
                }
                showTemporaryMessage("🐉 \(card.value) dmg!")
            }
        } else if card.name.contains("Meditar") || card.nameEn.contains("Meditate") {
            player.energy = min(player.maxEnergy + 2, player.energy + 2)
            player.heal(5)
            showTemporaryMessage("🧘 +2 energía +5 HP!")
        }
    }
    
    func checkTurnEnd() {
        if enemies.isEmpty {
            if wave >= 20 {
                gameWon = true
            }
            waveComplete()
            return
        }
        
        if player.energy <= 0 || player.hand.isEmpty {
            endPlayerTurn()
        }
    }
    
    func endPlayerTurn() {
        guard state == .playerTurn else { return }
        state = .enemyTurn
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.executeEnemyTurn()
        }
    }
    
    func executeEnemyTurn() {
        for i in enemies.indices {
            enemies[i].processPoison()
        }
        enemies.removeAll { $0.isDead }
        
        if enemies.isEmpty {
            if wave >= 20 {
                gameWon = true
            }
            waveComplete()
            return
        }
        
        var totalDamage = 0
        
        for enemy in enemies {
            switch enemy.intent {
            case .attack(let damage):
                totalDamage += damage
            case .attackTwice(let damage):
                totalDamage += damage * 2
            case .defend(let block):
                enemyBlock += block
            case .buff:
                break
            case .debuff:
                player.damageBuff = max(0, player.damageBuff - 3)
                showTemporaryMessage("📉 Tu daño reducido!")
            case .heal(let amount):
                if !enemies.isEmpty {
                    enemies[0].hp = min(enemies[0].maxHp, enemies[0].hp + amount)
                    showTemporaryMessage("💚 Enemigo sanado!")
                }
            case .summon:
                break
            }
        }
        
        let actualDamage = max(0, totalDamage - playerBlock - enemyBlock)
        
        if playerBlock > 0 || enemyBlock > 0 {
            showTemporaryMessage("🛡️ Bloqueado: \(playerBlock + enemyBlock)")
        }
        
        if actualDamage > 0 {
            player.takeDamage(actualDamage)
            showTemporaryMessage("💔 -\(actualDamage) HP!")
        }
        
        playerBlock = 0
        enemyBlock = 0
        
        if player.isDead {
            gameOver()
            return
        }
        
        generateEnemyIntents()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.startPlayerTurn()
        }
    }
    
    func startPlayerTurn() {
        guard state == .enemyTurn else { return }
        
        player.endTurn()
        player.startTurn()
        state = .playerTurn
        showTemporaryMessage("🎮 \(player.playerClass.name) - lvl \(player.level)")
    }
    
    func waveComplete() {
        let waveBonus = wave * 50
        let goldBonus = wave * 15
        score += waveBonus
        player.addGold(goldBonus)
        player.addExperience(wave * 20)
        
        // Calculate gems
        let waveGems = wave * 2
        gemsEarned = waveGems
        
        shopCards = Card.allCards.filter { card in
            switch player.level {
            case 1: return card.rarity == .common
            case 2: return card.rarity == .common || card.rarity == .uncommon
            case 3: return card.rarity != .legendary
            default: return true
            }
        }.shuffled().prefix(6).map { $0 }
        
        state = .waveComplete
    }
    
    func gameOver() {
        // Save progression
        progression = PlayerProgression.current
        progression.completeGame(wave: wave, score: score, won: gameWon)
        PlayerProgression.current = progression
        
        if score > highScore {
            highScore = score
        }
        state = .gameOver
    }
    
    func buyCard(_ card: Card) {
        let price = card.cost * 15
        if player.gold >= price {
            player.gold -= price
            player.addCardToDeck(card)
            shopCards.removeAll { $0.id == card.id }
            showTemporaryMessage("✅ Comprado!")
        } else {
            showTemporaryMessage("💰 Necesitas \(price) gold!")
        }
    }
    
    // MARK: - Relic Shop
    
    func openRelicShop() {
        availableRelics = RelicShop.getAvailableRelics()
        state = .relicShop
    }
    
    func buyRelic(_ relic: Relic) {
        let price = RelicShop.getRelicPrice(for: relic.rarity)
        progression = PlayerProgression.current
        
        if progression.gems >= price {
            progression.gems -= price
            progression.addRelic(relic.id)
            PlayerProgression.current = progression
            availableRelics.removeAll { $0.id == relic.id }
            showTemporaryMessage("✅ \(relic.name) conseguida!")
        } else {
            showTemporaryMessage("💎 Necesitas \(price) gemas!")
        }
    }
    
    func equipRelic(_ relic: Relic) {
        progression = PlayerProgression.current
        progression.equipRelic(relic.id)
        PlayerProgression.current = progression
        showTemporaryMessage("✅ \(relic.name) equipada!")
    }
    
    func unequipRelic(_ relic: Relic) {
        progression = PlayerProgression.current
        progression.unequipRelic(relic.id)
        PlayerProgression.current = progression
    }
    
    func unlockClass(_ playerClass: PlayerClass) {
        progression = PlayerProgression.current
        let cost = playerClass.unlockCost
        
        if progression.gems >= cost {
            progression.gems -= cost
            progression.unlockClass(playerClass)
            PlayerProgression.current = progression
            showTemporaryMessage("✅ \(playerClass.name) desbloqueada!")
        } else {
            showTemporaryMessage("💎 Necesitas \(cost) gemas!")
        }
    }
    
    func claimGems() {
        progression = PlayerProgression.current
        progression.addGems(gemsEarned)
        PlayerProgression.current = progression
        gemsEarned = 0
    }
    
    private func showTemporaryMessage(_ msg: String) {
        message = msg
        showMessage = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.showMessage = false
        }
    }
}
