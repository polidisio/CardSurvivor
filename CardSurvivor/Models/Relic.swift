import Foundation

// MARK: - Rarity
enum Rarity: String, CaseIterable, Codable {
    case common    // Gris
    case uncommon  // Verde
    case rare      // Azul
    case epic      // Púrpura
    case legendary // Dorado
    
    var color: String {
        switch self {
        case .common: return "808080"
        case .uncommon: return "30D158"
        case .rare: return "0A84FF"
        case .epic: return "BF5AF2"
        case .legendary: return "FFD60A"
        }
    }
}

// MARK: - Relic Type
enum RelicType: String, Codable {
    case extraHP
    case extraDamage
    case extraBlock
    case extraEnergy
    case lifesteal
    case extraCardDraw
    case goldMultiplier
    case expMultiplier
    case regeneration
    case criticalChance
    case dodge
}

// MARK: - Relic
struct Relic: Identifiable, Codable {
    let id: String
    let name: String
    let nameEn: String
    let description: String
    let rarity: Rarity
    let type: RelicType
    let value: Int
    let icon: String
    let targetClass: PlayerClass? // nil = todas las clases
    
    var isOwned: Bool {
        get { UserDefaults.standard.bool(forKey: "relic_\(id)_owned") }
        set { UserDefaults.standard.set(newValue, forKey: "relic_\(id)_owned") }
    }
    
    var effectiveFor: PlayerClass {
        targetClass ?? .warrior
    }
    
    static var allRelics: [Relic] {
        [
            // === RELIQUIAS GENÉRICAS (todas las clases) ===
            
            // COMMON
            Relic(id: "old_key", name: "Llave Antigua", nameEn: "Old Key", description: "+5 HP máx", rarity: .common, type: .extraHP, value: 5, icon: "key.fill", targetClass: nil),
            Relic(id: "rusty_coin", name: "Moneda Oxidada", nameEn: "Rusty Coin", description: "+10% Oro", rarity: .common, type: .goldMultiplier, value: 10, icon: "centsign.circle", targetClass: nil),
            Relic(id: "broken_shield", name: "Escudo Roto", nameEn: "Broken Shield", description: "+3 Bloqueo", rarity: .common, type: .extraBlock, value: 3, icon: "shield.slash", targetClass: nil),
            Relic(id: "stone", name: "Piedra", nameEn: "Stone", description: "+2 Daño", rarity: .common, type: .extraDamage, value: 2, icon: "circle.fill", targetClass: nil),
            
            // UNCOMMON
            Relic(id: "silver_pendant", name: "Collar de Plata", nameEn: "Silver Pendant", description: "+10 HP máx", rarity: .uncommon, type: .extraHP, value: 10, icon: "sparkles", targetClass: nil),
            Relic(id: "vintage_book", name: "Libro Vintage", nameEn: "Vintage Book", description: "+1 Robar cartas", rarity: .uncommon, type: .extraCardDraw, value: 1, icon: "book.fill", targetClass: nil),
            Relic(id: "royal_scepter", name: "Cetro Real", nameEn: "Royal Scepter", description: "+15% Oro", rarity: .rare, type: .goldMultiplier, value: 15, icon: "crown.fill", targetClass: nil),
            Relic(id: "ancient_tome", name: "Tomo Antiguo", nameEn: "Ancient Tome", description: "+15% XP", rarity: .rare, type: .expMultiplier, value: 15, icon: "book.closed.fill", targetClass: nil),
            
            // === RELIQUIAS DEL GUERRERO ===
            Relic(id: "warrior_gloves", name: "Guantes de Guerra", nameEn: "Warrior Gloves", description: "+5 Daño", rarity: .common, type: .extraDamage, value: 5, icon: "hand.raised.fill", targetClass: .warrior),
            Relic(id: "warrior_helm", name: "Elmo del Capitán", nameEn: "Captain's Helm", description: "+15 HP máx", rarity: .uncommon, type: .extraHP, value: 15, icon: "shield.fill", targetClass: .warrior),
            Relic(id: "warrior_axe", name: "Hacha de Batalla", nameEn: "Battle Axe", description: "+10 Daño", rarity: .rare, type: .extraDamage, value: 10, icon: "axe.fill", targetClass: .warrior),
            Relic(id: "warrior_armor", name: "Armadura de Acero", nameEn: "Steel Armor", description: "+10 Bloqueo", rarity: .rare, type: .extraBlock, value: 10, icon: "shield.lefthalf.filled", targetClass: .warrior),
            Relic(id: "warrior_master", name: "Espada Legendaria", nameEn: "Legendary Sword", description: "+20 Daño", rarity: .epic, type: .extraDamage, value: 20, icon: "sword.fill", targetClass: .warrior),
            Relic(id: "warrior_crown", name: "Corona del Rey Guerrero", nameEn: "Crown of the Warrior King", description: "+30% Daño", rarity: .legendary, type: .extraDamage, value: 30, icon: "crown.fill", targetClass: .warrior),
            
            // === RELIQUIAS DEL MAGO ===
            Relic(id: "mage_wand", name: "Varita de Aprendiz", nameEn: "Apprentice Wand", description: "+1 Energía máx", rarity: .common, type: .extraEnergy, value: 1, icon: "wand.and.stars", targetClass: .mage),
            Relic(id: "mage_crystal", name: "Cristal Mágico", nameEn: "Magic Crystal", description: "+2 Energía máx", rarity: .uncommon, type: .extraEnergy, value: 2, icon: "diamond.fill", targetClass: .mage),
            Relic(id: "mage_tome", name: "Tomo Arcano", nameEn: "Arcane Tome", description: "+1 Robar cartas", rarity: .rare, type: .extraCardDraw, value: 1, icon: "book.fill", targetClass: .mage),
            Relic(id: "mage_staff", name: "Báculo del Archimago", nameEn: "Archmage Staff", description: "+3 Energía máx", rarity: .epic, type: .extraEnergy, value: 3, icon: "staff.fill", targetClass: .mage),
            Relic(id: "mage_orb", name: "Orbe del Poder", nameEn: "Orb of Power", description: "+2 Robar cartas", rarity: .epic, type: .extraCardDraw, value: 2, icon: "circle.hexagongrid.fill", targetClass: .mage),
            Relic(id: "mage_crown", name: "Corona del Archimago", nameEn: "Archmage Crown", description: "+4 Energía máx", rarity: .legendary, type: .extraEnergy, value: 4, icon: "crown.fill", targetClass: .mage),
            
            // === RELIQUIAS DEL PÍCARO ===
            Relic(id: "rogue_dagger", name: "Daga Envenenada", nameEn: "Poisoned Dagger", description: "+5% Robo vida", rarity: .common, type: .lifesteal, value: 5, icon: "knife", targetClass: .rogue),
            Relic(id: "rogue_ring", name: "Anillo del Asesino", nameEn: "Assassin's Ring", description: "+10% Robo vida", rarity: .uncommon, type: .lifesteal, value: 10, icon: "circle.fill", targetClass: .rogue),
            Relic(id: "rogue_cloak", name: "Capa de Sombras", nameEn: "Cloak of Shadows", description: "+10% Crit", rarity: .rare, type: .criticalChance, value: 10, icon: "wind", targetClass: .rogue),
            Relic(id: "rogue_poison", name: "Veneno Mortal", nameEn: "Deadly Poison", description: "+15% Robo vida", rarity: .epic, type: .lifesteal, value: 15, icon: "flame.fill", targetClass: .rogue),
            Relic(id: "rogue_master", name: "Espada Fantasma", nameEn: "Ghost Sword", description: "+20% Robo vida", rarity: .epic, type: .lifesteal, value: 20, icon: "ghost.fill", targetClass: .rogue),
            Relic(id: "rogue_crown", name: "Corona del Maestro Asesino", nameEn: "Master Assassin Crown", description: "+30% Robo vida", rarity: .legendary, type: .lifesteal, value: 30, icon: "crown.fill", targetClass: .rogue),
            
            // === RELIQUIAS DEL PALADÍN ===
            Relic(id: "paladin_holy_symbol", name: "Símbolo Sagrado", nameEn: "Holy Symbol", description: "+2 Regeneración", rarity: .common, type: .regeneration, value: 2, icon: "star.fill", targetClass: .paladin),
            Relic(id: "paladin_shield", name: "Escudo Bendito", nameEn: "Blessed Shield", description: "+10 HP máx", rarity: .uncommon, type: .extraHP, value: 10, icon: "shield.fill", targetClass: .paladin),
            Relic(id: "paladin_hammer", name: "Martillo Santo", nameEn: "Holy Hammer", description: "+5 Daño", rarity: .rare, type: .extraDamage, value: 5, icon: "hammer.fill", targetClass: .paladin),
            Relic(id: "paladin_aura", name: "Aura de Luz", nameEn: "Aura of Light", description: "+3 Regeneración", rarity: .epic, type: .regeneration, value: 3, icon: "sun.max.fill", targetClass: .paladin),
            Relic(id: "paladin_armor", name: "Armadura Divina", nameEn: "Divine Armor", description: "+20 HP máx", rarity: .epic, type: .extraHP, value: 20, icon: "shield.lefthalf.filled", targetClass: .paladin),
            Relic(id: "paladin_crown", name: "Corona del Santo", nameEn: "Saint's Crown", description: "+5 Regeneración", rarity: .legendary, type: .regeneration, value: 5, icon: "crown.fill", targetClass: .paladin),
        ]
    }
    
    static func relic(byId id: String) -> Relic? {
        allRelics.first { $0.id == id }
    }
}

// MARK: - Player Progression
struct PlayerProgression: Codable {
    var gems: Int = 0
    var totalWins: Int = 0
    var totalGames: Int = 0
    var bestWave: Int = 0
    var bestScore: Int = 0
    var unlockedClasses: [PlayerClass] = [.warrior]
    var ownedRelics: [String] = []
    var equippedRelics: [String] = []
    
    static var key: String { "player_progression" }
    
    static var current: PlayerProgression {
        get {
            guard let data = UserDefaults.standard.data(forKey: key),
                  let progression = try? JSONDecoder().decode(PlayerProgression.self, from: data) else {
                return PlayerProgression()
            }
            return progression
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: key)
            }
        }
    }
    
    mutating func addGems(_ amount: Int) {
        gems += amount
    }
    
    mutating func addRelic(_ relicId: String) {
        if !ownedRelics.contains(relicId) {
            ownedRelics.append(relicId)
        }
    }
    
    mutating func equipRelic(_ relicId: String) {
        if ownedRelics.contains(relicId) && equippedRelics.count < 3 {
            if !equippedRelics.contains(relicId) {
                equippedRelics.append(relicId)
            }
        }
    }
    
    mutating func unequipRelic(_ relicId: String) {
        equippedRelics.removeAll { $0 == relicId }
    }
    
    mutating func unlockClass(_ playerClass: PlayerClass) {
        if !unlockedClasses.contains(playerClass) {
            unlockedClasses.append(playerClass)
        }
    }
    
    mutating func completeGame(wave: Int, score: Int, won: Bool) {
        totalGames += 1
        if won {
            totalWins += 1
        }
        if wave > bestWave {
            bestWave = wave
        }
        if score > bestScore {
            bestScore = score
        }
        
        // Calculate gem rewards
        let waveGems = wave * 2
        let winBonus = won ? wave * 5 : 0
        let newGems = waveGems + winBonus
        
        gems += newGems
        
        // Award relics based on performance
        if won {
            // Win rewards
            if wave >= 5 && Int.random(in: 1...100) <= 30 { addRandomRelic(.rare) }
            if wave >= 10 && Int.random(in: 1...100) <= 20 { addRandomRelic(.epic) }
        } else {
            // Loss rewards
            if wave >= 3 && Int.random(in: 1...100) <= 20 { addRandomRelic(.common) }
            if wave >= 5 && Int.random(in: 1...100) <= 10 { addRandomRelic(.uncommon) }
        }
        
        PlayerProgression.current = self
    }
    
    private mutating func addRandomRelic(_ minRarity: Rarity) {
        let ownedIds = Set(ownedRelics)
        let available = Relic.allRelics.filter { !ownedIds.contains($0.id) && $0.rarity.rawValue >= minRarity.rawValue }
        
        if let random = available.randomElement() {
            addRelic(random.id)
        }
    }
}

// MARK: - Relic Shop
struct RelicShop {
    static func getAvailableRelics() -> [Relic] {
        let progression = PlayerProgression.current
        let ownedIds = Set(progression.ownedRelics)
        
        return Relic.allRelics
            .filter { !ownedIds.contains($0.id) }
            .shuffled()
            .prefix(4)
            .map { $0 }
    }
    
    static func getRelicPrice(for rarity: Rarity) -> Int {
        switch rarity {
        case .common: return 50
        case .uncommon: return 100
        case .rare: return 250
        case .epic: return 500
        case .legendary: return 1000
        }
    }
}
