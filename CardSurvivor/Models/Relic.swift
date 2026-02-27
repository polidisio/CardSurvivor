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
    
    var isOwned: Bool {
        get { UserDefaults.standard.bool(forKey: "relic_\(id)_owned") }
        set { UserDefaults.standard.set(newValue, forKey: "relic_\(id)_owned") }
    }
    
    static var allRelics: [Relic] {
        [
            // COMMON - Easy to get
            Relic(id: "old_key", name: "Llave Antigua", nameEn: "Old Key", description: "+5 HP máx", rarity: .common, type: .extraHP, value: 5, icon: "key.fill"),
            Relic(id: "rusty_coin", name: "Moneda Oxidada", nameEn: "Rusty Coin", description: "+10% Gold", rarity: .common, type: .goldMultiplier, value: 10, icon: "centsign.circle"),
            Relic(id: "broken_shield", name: "Escudo Roto", nameEn: "Broken Shield", description: "+3 Bloqueo", rarity: .common, type: .extraBlock, value: 3, icon: "shield.slash"),
            Relic(id: "stone", name: "Piedra", nameEn: "Stone", description: "+2 Daño", rarity: .common, type: .extraDamage, value: 2, icon: "circle.fill"),
            
            // UNCOMMON
            Relic(id: "silver_pendant", name: "Collar de Plata", nameEn: "Silver Pendant", description: "+10 HP máx", rarity: .uncommon, type: .extraHP, value: 10, icon: "sparkles"),
            Relic(id: "dagger", name: "Daga Vieja", nameEn: "Old Dagger", description: "+5 Daño", rarity: .uncommon, type: .extraDamage, value: 5, icon: "knife"),
            Relic(id: "energy_crystal", name: "Cristal de Energía", nameEn: "Energy Crystal", description: "+1 Energía máx", rarity: .uncommon, type: .extraEnergy, value: 1, icon: "bolt.fill"),
            Relic(id: "vintage_book", name: "Libro Vintage", nameEn: "Vintage Book", description: "+1 Robar cartas", rarity: .uncommon, type: .extraCardDraw, value: 1, icon: "book.fill"),
            
            // RARE
            Relic(id: "gold_ring", name: "Anillo de Oro", nameEn: "Gold Ring", description: "+5% Robovida", rarity: .rare, type: .lifesteal, value: 5, icon: "heart.circle"),
            Relic(id: "royal_scepter", name: "Cetro Real", nameEn: "Royal Scepter", description: "+15% Gold", rarity: .rare, type: .goldMultiplier, value: 15, icon: "crown.fill"),
            Relic(id: "ancient_tome", name: "Tomo Antiguo", nameEn: "Ancient Tome", description: "+15% XP", rarity: .rare, type: .expMultiplier, value: 15, icon: "book.closed.fill"),
            Relic(id: "emerald", name: "Esmeralda", nameEn: "Emerald", description: "+15 HP máx", rarity: .rare, type: .extraHP, value: 15, icon: "diamond.fill"),
            
            // EPIC
            Relic(id: "ruby", name: "Rubí", nameEn: "Ruby", description: "+10% Robovida", rarity: .epic, type: .lifesteal, value: 10, icon: "heart.fill"),
            Relic(id: "sapphire", name: "Zafiro", nameEn: "Sapphire", description: "+2 Energía máx", rarity: .epic, type: .extraEnergy, value: 2, icon: "hexagon.fill"),
            Relic(id: "dragon_scale", name: "Escama de Dragón", nameEn: "Dragon Scale", description: "+10 Daño", rarity: .epic, type: .extraDamage, value: 10, icon: "flame.fill"),
            
            // LEGENDARY
            Relic(id: "crown", name: "Corona", nameEn: "Crown", description: "+25% Todo", rarity: .legendary, type: .extraDamage, value: 25, icon: "crown.fill"),
            Relic(id: "phoenix", name: "Pluma de Fénix", nameEn: "Phoenix Feather", description: "+30 HP + Respawn", rarity: .legendary, type: .extraHP, value: 30, icon: "sun.max.fill"),
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
