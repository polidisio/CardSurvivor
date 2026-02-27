import Foundation

enum PlayerClass: String, CaseIterable, Identifiable, Codable {
    case warrior, mage, rogue, paladin
    
    var id: String { rawValue }
    
    var name: String {
        switch self {
        case .warrior: return "Guerrero"
        case .mage: return "Mago"
        case .rogue: return "Pícaro"
        case .paladin: return "Paladín"
        }
    }
    
    var nameEn: String {
        switch self {
        case .warrior: return "Warrior"
        case .mage: return "Mage"
        case .rogue: return "Rogue"
        case .paladin: return "Paladin"
        }
    }
    
    var description: String {
        switch self {
        case .warrior: return "Alta vida y daño físico."
        case .mage: return "Baja vida pero magia poderosa."
        case .rogue: return "Velocidad y robo de vida."
        case .paladin: return "Equilibrado. Sanación y defensa."
        }
    }
    
    var icon: String {
        switch self {
        case .warrior: return "shield.fill"
        case .mage: return "wand.and.stars"
        case .rogue: return "bolt.fill"
        case .paladin: return "cross.case.fill"
        }
    }
    
    var baseHP: Int { 60 }
    var baseEnergy: Int { 3 }
    var baseDamage: Int { 10 }
    
    var unlockCost: Int {
        switch self {
        case .warrior: return 0
        case .mage: return 100
        case .rogue: return 150
        case .paladin: return 200
        }
    }
    
    var passiveAbility: String {
        switch self {
        case .warrior: return "Daño aumentado un 20%"
        case .mage: return "Cartas de poder cuestan 1 menos"
        case .rogue: return "20% probabilidad de robo de vida"
        case .paladin: return "Regenera 2 HP por turno"
        }
    }
}

struct Player {
    var playerClass: PlayerClass
    var hp: Int
    var maxHp: Int
    var gold: Int
    var deck: [Card]
    var hand: [Card]
    var discardPile: [Card]
    var drawPile: [Card]
    var energy: Int
    var maxEnergy: Int
    var damageBuff: Int = 0
    var damageBuffTurns: Int = 0
    var defenseBuff: Int = 0
    var defenseBuffTurns: Int = 0
    
    var level: Int = 1
    var experience: Int = 0
    let expToLevelUp: Int = 100
    
    var lifestealPercent: Int = 0
    var regeneration: Int = 0
    var extraCardDraw: Int = 0
    
    var relicBonusHP: Int = 0
    var relicBonusDamage: Int = 0
    var relicBonusBlock: Int = 0
    var relicBonusEnergy: Int = 0
    var relicBonusLifesteal: Int = 0
    var relicBonusCardDraw: Int = 0
    var relicGoldMultiplier: Double = 1.0
    var relicExpMultiplier: Double = 1.0
    
    init(playerClass: PlayerClass = .warrior) {
        self.playerClass = playerClass
        
        let progression = PlayerProgression.current
        
        for relicId in progression.equippedRelics {
            if let relic = Relic.relic(byId: relicId) {
                switch relic.type {
                case .extraHP: relicBonusHP += relic.value
                case .extraDamage: relicBonusDamage += relic.value
                case .extraBlock: relicBonusBlock += relic.value
                case .extraEnergy: relicBonusEnergy += relic.value
                case .lifesteal: relicBonusLifesteal += relic.value
                case .extraCardDraw: relicBonusCardDraw += relic.value
                case .goldMultiplier: relicGoldMultiplier += Double(relic.value) / 100.0
                case .expMultiplier: relicExpMultiplier += Double(relic.value) / 100.0
                }
            }
        }
        
        let hpBonus = playerClass == .paladin ? 10 : (playerClass == .warrior ? 20 : 0)
        let energyBonus = playerClass == .mage ? 1 : 0
        let baseDamage = playerClass == .rogue ? 2 : 0
        
        self.maxHp = playerClass.baseHP + hpBonus + relicBonusHP
        self.hp = maxHp
        self.maxEnergy = playerClass.baseEnergy + energyBonus + relicBonusEnergy
        self.energy = self.maxEnergy
        self.gold = 0
        
        switch playerClass {
        case .warrior:
            self.damageBuff = Int(Double(playerClass.baseDamage) * 0.20) + relicBonusDamage
        case .rogue:
            self.damageBuff = baseDamage + relicBonusDamage
            self.lifestealPercent = 20 + relicBonusLifesteal
        case .paladin:
            self.regeneration = 2
        default:
            self.damageBuff = relicBonusDamage
        }
        
        self.extraCardDraw = relicBonusCardDraw
        
        self.deck = Player.createStartingDeck(for: playerClass)
        self.hand = []
        self.discardPile = []
        self.drawPile = self.deck.shuffled()
    }
    
    static func createStartingDeck(for playerClass: PlayerClass) -> [Card] {
        var deck: [Card] = []
        
        switch playerClass {
        case .warrior:
            deck = [
                Card(name: "Golpe", nameEn: "Strike", description: "6 de daño", descriptionEn: "Deal 6 damage", type: .attack, cost: 1, value: 6, rarity: .common),
                Card(name: "Golpe", nameEn: "Strike", description: "6 de daño", descriptionEn: "Deal 6 damage", type: .attack, cost: 1, value: 6, rarity: .common),
                Card(name: "Golpe", nameEn: "Strike", description: "6 de daño", descriptionEn: "Deal 6 damage", type: .attack, cost: 1, value: 6, rarity: .common),
                Card(name: "Corte", nameEn: "Slash", description: "10 de daño", descriptionEn: "Deal 10 damage", type: .attack, cost: 2, value: 10, rarity: .common),
                Card(name: "Corte", nameEn: "Slash", description: "10 de daño", descriptionEn: "Deal 10 damage", type: .attack, cost: 2, value: 10, rarity: .common),
                Card(name: "Escudo", nameEn: "Shield", description: "Bloquea 5", descriptionEn: "Block 5", type: .defense, cost: 1, value: 5, rarity: .common),
                Card(name: "Escudo", nameEn: "Shield", description: "Bloquea 5", descriptionEn: "Block 5", type: .defense, cost: 1, value: 5, rarity: .common),
                Card(name: "Pared", nameEn: "Wall", description: "Bloquea 10", descriptionEn: "Block 10", type: .defense, cost: 2, value: 10, rarity: .common),
                Card(name: "Pared", nameEn: "Wall", description: "Bloquea 10", descriptionEn: "Block 10", type: .defense, cost: 2, value: 10, rarity: .common),
            ]
        case .mage:
            deck = [
                Card(name: "Proyectil", nameEn: "Orb", description: "8 de daño", descriptionEn: "Deal 8 damage", type: .attack, cost: 1, value: 8, rarity: .common),
                Card(name: "Proyectil", nameEn: "Orb", description: "8 de daño", descriptionEn: "Deal 8 damage", type: .attack, cost: 1, value: 8, rarity: .common),
                Card(name: "Bola de Fuego", nameEn: "Fireball", description: "15 de daño", descriptionEn: "Deal 15 damage", type: .attack, cost: 2, value: 15, rarity: .uncommon),
                Card(name: "Escarcha", nameEn: "Frost", description: "12 de daño", descriptionEn: "12 damage", type: .attack, cost: 2, value: 12, rarity: .uncommon),
                Card(name: "Veneno", nameEn: "Poison", description: "Envenena", descriptionEn: "Poison", type: .power, cost: 1, value: 3, rarity: .common),
                Card(name: "Veneno", nameEn: "Poison", description: "Envenena", descriptionEn: "Poison", type: .power, cost: 1, value: 3, rarity: .common),
                Card(name: "Curación", nameEn: "Heal", description: "Cura 10", descriptionEn: "Heal 10", type: .power, cost: 2, value: 10, rarity: .common),
                Card(name: "Robar", nameEn: "Draw", description: "Roba 2", descriptionEn: "Draw 2", type: .draw, cost: 0, value: 2, rarity: .common),
            ]
        case .rogue:
            deck = [
                Card(name: "Puñalada", nameEn: "Dagger", description: "5 daño", descriptionEn: "5 damage", type: .attack, cost: 1, value: 5, rarity: .common),
                Card(name: "Puñalada", nameEn: "Dagger", description: "5 daño", descriptionEn: "5 damage", type: .attack, cost: 1, value: 5, rarity: .common),
                Card(name: "Puñalada", nameEn: "Dagger", description: "5 daño", descriptionEn: "5 damage", type: .attack, cost: 1, value: 5, rarity: .common),
                Card(name: "Ataque Rápido", nameEn: "Quick Strike", description: "8 de daño", descriptionEn: "Deal 8 damage", type: .attack, cost: 1, value: 8, rarity: .common),
                Card(name: "Ataque Rápido", nameEn: "Quick Strike", description: "8 de daño", descriptionEn: "Deal 8 damage", type: .attack, cost: 1, value: 8, rarity: .common),
                Card(name: "Golpe Crítico", nameEn: "Critical", description: "12 daño", descriptionEn: "Double damage", type: .attack, cost: 2, value: 12, rarity: .uncommon),
                Card(name: "Robar", nameEn: "Steal", description: "Roba vida", descriptionEn: "Lifesteal", type: .power, cost: 1, value: 5, rarity: .common),
                Card(name: "Velocidad", nameEn: "Haste", description: "Dibuja cartas", descriptionEn: "Draw cards", type: .draw, cost: 0, value: 2, rarity: .common),
            ]
        case .paladin:
            deck = [
                Card(name: "Golpe", nameEn: "Strike", description: "6 de daño", descriptionEn: "Deal 6 damage", type: .attack, cost: 1, value: 6, rarity: .common),
                Card(name: "Golpe", nameEn: "Strike", description: "6 de daño", descriptionEn: "Deal 6 damage", type: .attack, cost: 1, value: 6, rarity: .common),
                Card(name: "Golpe", nameEn: "Strike", description: "6 de daño", descriptionEn: "Deal 6 damage", type: .attack, cost: 1, value: 6, rarity: .common),
                Card(name: "Escudo", nameEn: "Shield", description: "Bloquea 5", descriptionEn: "Block 5", type: .defense, cost: 1, value: 5, rarity: .common),
                Card(name: "Escudo", nameEn: "Shield", description: "Bloquea 5", descriptionEn: "Block 5", type: .defense, cost: 1, value: 5, rarity: .common),
                Card(name: "Escudo", nameEn: "Shield", description: "Bloquea 5", descriptionEn: "Block 5", type: .defense, cost: 1, value: 5, rarity: .common),
                Card(name: "Curación", nameEn: "Heal", description: "Cura 10", descriptionEn: "Heal 10", type: .power, cost: 2, value: 10, rarity: .common),
                Card(name: "Curación", nameEn: "Heal", description: "Cura 10", descriptionEn: "Heal 10", type: .power, cost: 2, value: 10, rarity: .common),
            ]
        }
        
        return deck
    }
    
    mutating func startTurn() {
        energy = maxEnergy
        
        if damageBuffTurns > 0 {
            damageBuffTurns -= 1
            if damageBuffTurns <= 0 { damageBuff = relicBonusDamage }
        }
        
        if defenseBuffTurns > 0 {
            defenseBuffTurns -= 1
            if defenseBuffTurns <= 0 { defenseBuff = 0 }
        }
        
        if regeneration > 0 {
            hp = min(maxHp, hp + regeneration)
        }
        
        drawCards(4 + extraCardDraw)
    }
    
    mutating func drawCards(_ count: Int) {
        for _ in 0..<count {
            if drawPile.isEmpty {
                drawPile = discardPile.shuffled()
                discardPile.removeAll()
            }
            
            if !drawPile.isEmpty && hand.count < 10 {
                hand.append(drawPile.removeFirst())
            }
        }
    }
    
    mutating func endTurn() {
        discardPile.append(contentsOf: hand)
        hand.removeAll()
    }
    
    mutating func takeDamage(_ damage: Int) {
        hp = max(0, hp - damage)
    }
    
    mutating func heal(_ amount: Int) {
        hp = min(maxHp, hp + amount)
    }
    
    mutating func addGold(_ amount: Int) {
        gold += Int(Double(amount) * relicGoldMultiplier)
    }
    
    mutating func addCardToDeck(_ card: Card) {
        deck.append(card)
    }
    
    mutating func removeCardFromDeck(_ card: Card) {
        deck.removeAll { $0.id == card.id }
    }
    
    mutating func addExperience(_ amount: Int) {
        let adjustedAmount = Int(Double(amount) * relicExpMultiplier)
        experience += adjustedAmount
        if experience >= expToLevelUp {
            levelUp()
        }
    }
    
    mutating func levelUp() {
        experience -= expToLevelUp
        level += 1
        
        switch playerClass {
        case .warrior:
            let newMax = maxHp + 15
            hp = min(hp + 15, newMax)
            damageBuff += 3
        case .mage:
            let newMax = maxHp + 5
            hp = min(hp + 5, newMax)
            extraCardDraw += 1
        case .rogue:
            let newMax = maxHp + 10
            hp = min(hp + 10, newMax)
            lifestealPercent += 2
        case .paladin:
            let newMax = maxHp + 20
            hp = min(hp + 20, newMax)
            regeneration += 2
        }
    }
    
    var isDead: Bool { hp <= 0 }
    
    var experienceProgress: Double {
        Double(experience) / Double(expToLevelUp)
    }
}
