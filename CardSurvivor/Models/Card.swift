import Foundation

// MARK: - Card Model
struct Card: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let nameEn: String
    let description: String
    let descriptionEn: String
    let type: CardType
    let cost: Int
    let value: Int
    let rarity: CardRarity
    
    enum CardType: String, Codable {
        case attack
        case defense
        case power
        case draw
        case special
    }
    
    enum CardRarity: String, Codable {
        case common
        case uncommon
        case rare
        case epic
        case legendary
    }
    
    init(id: UUID = UUID(), name: String, nameEn: String, description: String, descriptionEn: String, type: CardType, cost: Int, value: Int, rarity: CardRarity) {
        self.id = id
        self.name = name
        self.nameEn = nameEn
        self.description = description
        self.descriptionEn = descriptionEn
        self.type = type
        self.cost = cost
        self.value = value
        self.rarity = rarity
    }
}

// MARK: - Extended Card Library
extension Card {
    static let allCards: [Card] = [
        // === ATTACK CARDS ===
        // Common (1 cost)
        Card(name: "Golpe", nameEn: "Strike", description: "Inflige 6 de daño", descriptionEn: "Deal 6 damage", type: .attack, cost: 1, value: 6, rarity: .common),
        Card(name: "Ataque Rápido", nameEn: "Quick Attack", description: "Inflige 4 de daño + robo de vida", descriptionEn: "Deal 4 damage + lifesteal", type: .attack, cost: 1, value: 4, rarity: .common),
        
        // Common (2 cost)
        Card(name: "Corte", nameEn: "Slash", description: "Inflige 10 de daño", descriptionEn: "Deal 10 damage", type: .attack, cost: 2, value: 10, rarity: .common),
        Card(name: "Combate", nameEn: "Brawl", description: "Inflige 8 de daño + vulnerable", descriptionEn: "Deal 8 damage + vulnerable", type: .attack, cost: 2, value: 8, rarity: .common),
        
        // Uncommon (2 cost)
        Card(name: "Golpe Crítico", nameEn: "Critical Hit", description: "50% probabilidad de daño doble", descriptionEn: "50% chance double damage", type: .attack, cost: 2, value: 12, rarity: .uncommon),
        
        // Uncommon (3 cost)
        Card(name: "Estocada", nameEn: "Thrust", description: "Inflige 15 de daño", descriptionEn: "Deal 15 damage", type: .attack, cost: 3, value: 15, rarity: .uncommon),
        Card(name: "Espadazo", nameEn: "Sword Slash", description: "Inflige 12 de daño + debilitar", descriptionEn: "Deal 12 damage + weaken", type: .attack, cost: 3, value: 12, rarity: .uncommon),
        
        // Rare (3 cost)
        Card(name: "Frenesí", nameEn: "Frenzy", description: "Inflige 20 de daño", descriptionEn: "Deal 20 damage", type: .attack, cost: 3, value: 20, rarity: .rare),
        
        // Rare (4 cost)
        Card(name: "Torbellino", nameEn: "Whirlwind", description: "Inflige 8 a TODOS los enemigos", descriptionEn: "Deal 8 to ALL enemies", type: .attack, cost: 4, value: 8, rarity: .rare),
        
        // Epic (4 cost)
        Card(name: "Ejecutar", nameEn: "Execute", description: "Si el enemigo tiene <25% HP, mata instantáneamente", descriptionEn: "If enemy <25% HP, kill instantly", type: .attack, cost: 4, value: 30, rarity: .epic),
        
        // Legendary (5 cost)
        Card(name: "Asesinato", nameEn: "Assassinate", description: "Ignora toda la defensa y mata", descriptionEn: "Ignore all defense and kill", type: .attack, cost: 5, value: 100, rarity: .legendary),
        
        // === DEFENSE CARDS ===
        // Common (1 cost)
        Card(name: "Escudo", nameEn: "Shield", description: "Bloquea 5 de daño", descriptionEn: "Block 5 damage", type: .defense, cost: 1, value: 5, rarity: .common),
        Card(name: "Parry", nameEn: "Parry", description: "Bloquea 4 + contraataque", descriptionEn: "Block 4 + counterattack", type: .defense, cost: 1, value: 4, rarity: .common),
        
        // Common (2 cost)
        Card(name: "Pared", nameEn: "Wall", description: "Bloquea 10 de daño", descriptionEn: "Block 10 damage", type: .defense, cost: 2, value: 10, rarity: .common),
        
        // Uncommon (2 cost)
        Card(name: "Refugio", nameEn: "Refuge", description: "Bloquea 12 +获者 3 de armadura", descriptionEn: "Block 12 + gain 3 armor", type: .defense, cost: 2, value: 12, rarity: .uncommon),
        
        // Uncommon (3 cost)
        Card(name: "Fortaleza", nameEn: "Fortress", description: "Bloquea 15 de daño", descriptionEn: "Block 15 damage", type: .defense, cost: 3, value: 15, rarity: .uncommon),
        Card(name: "Escudo Dorado", nameEn: "Golden Shield", description: "Bloquea 12 + robo de vida", descriptionEn: "Block 12 + lifesteal", type: .defense, cost: 3, value: 12, rarity: .uncommon),
        
        // Rare (3 cost)
        Card(name: "Inmunidad", nameEn: "Immunity", description: "Bloquea 20 + siguiente ataque gratis", descriptionEn: "Block 20 + next attack free", type: .defense, cost: 3, value: 20, rarity: .rare),
        
        // === POWER CARDS ===
        // Common (1 cost)
        Card(name: "Veneno", nameEn: "Poison", description: "Envenena (3 dmg/turno por 3 turnos)", descriptionEn: "Poison (3 dmg/turn for 3 turns)", type: .power, cost: 1, value: 3, rarity: .common),
        
        // Common (2 cost)
        Card(name: "Curación", nameEn: "Heal", description: "Cura 10 HP", descriptionEn: "Heal 10 HP", type: .power, cost: 2, value: 10, rarity: .common),
        
        // Uncommon (2 cost)
        Card(name: "Furia", nameEn: "Rage", description: "+5 daño durante 3 turnos", descriptionEn: "+5 damage for 3 turns", type: .power, cost: 2, value: 5, rarity: .uncommon),
        Card(name: "Regeneración", nameEn: "Regeneration", description: "Cura 5 HP al final de cada turno", descriptionEn: "Heal 5 HP end of each turn", type: .power, cost: 2, value: 5, rarity: .uncommon),
        
        // Uncommon (3 cost)
        Card(name: "Aura de Poder", nameEn: "Power Aura", description: "+8 daño durante 2 turnos", descriptionEn: "+8 damage for 2 turns", type: .power, cost: 3, value: 8, rarity: .uncommon),
        
        // Rare (3 cost)
        Card(name: "Berserker", nameEn: "Berserker", description: "+10 daño pero -5 HP cada turno", descriptionEn: "+10 damage but -5 HP each turn", type: .power, cost: 3, value: 10, rarity: .rare),
        
        // === DRAW CARDS ===
        // Common (0 cost)
        Card(name: "Robar", nameEn: "Draw", description: "Roba 2 cartas", descriptionEn: "Draw 2 cards", type: .draw, cost: 0, value: 2, rarity: .common),
        
        // Common (1 cost)
        Card(name: "Inspiración", nameEn: "Inspiration", description: "Roba 3 cartas + 1 energía", descriptionEn: "Draw 3 cards + 1 energy", type: .draw, cost: 1, value: 3, rarity: .uncommon),
        
        // === SPECIAL CARDS ===
        // Rare (2 cost)
        Card(name: "Meditar", nameEn: "Meditate", description: "Recupera 2 de energía + robo de vida", descriptionEn: "Restore 2 energy + lifesteal", type: .special, cost: 2, value: 2, rarity: .rare),
        
        // Epic (3 cost)
        Card(name: "Apocalipsis", nameEn: "Apocalypse", description: "Hace 5 de daño a TODOS los enemigos 3 veces", descriptionEn: "Deal 5 damage to ALL enemies 3 times", type: .special, cost: 3, value: 15, rarity: .epic),
        
        // Legendary (5 cost)
        Card(name: "Dragon", nameEn: "Dragon", description: "Inflige 50 de daño + aplica todos los efectos", descriptionEn: "Deal 50 damage + apply all effects", type: .special, cost: 5, value: 50, rarity: .legendary),
    ]
    
    static let sampleCards: [Card] = allCards.filter { $0.rarity == .common || $0.rarity == .uncommon }
}
