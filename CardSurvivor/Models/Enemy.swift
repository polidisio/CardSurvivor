import Foundation

// MARK: - Enemy Intent
enum EnemyIntent {
    case attack(damage: Int)
    case attackTwice(damage: Int)  // Two attacks
    case defend(block: Int)
    case buff
    case debuff
    case heal(amount: Int)
    case summon
}

// MARK: - Enemy Model
struct Enemy: Identifiable {
    let id: UUID
    let name: String
    let nameEn: String
    var hp: Int
    let maxHp: Int
    let baseDamage: Int
    var currentDamage: Int
    let defense: Int
    let type: EnemyType
    var isPoisoned: Bool = false
    var poisonDamage: Int = 0
    var poisonTurns: Int = 0
    var intent: EnemyIntent = .attack(damage: 0)
    var isElite: Bool = false  // Elite enemies are stronger
    
    enum EnemyType: String, Codable {
        case basic      // Zombi
        case fast       // Murciélago
        case tank       // Golem
        case boss       // Jefe de fase
        case finalBoss // Señor de las Sombras
        case scout      // Explorador - attacks weakest
        case mage       // Mago - uses magic
        case healer     // Sanador - heals enemies
        case swarm      // Swarm - many weak attacks
    }
    
    var isBoss: Bool {
        type == .boss || type == .finalBoss
    }
    
    var icon: String {
        switch type {
        case .basic: return "skull"
        case .fast: return "bolt.fill"
        case .tank: return "shield.fill"
        case .boss: return "crown.fill"
        case .finalBoss: return "moon.stars.fill"
        case .scout: return "eye.fill"
        case .mage: return "wand.and.stars"
        case .healer: return "cross.case.fill"
        case .swarm: return "hare.fill"
        }
    }
    
    var damage: Int { currentDamage }
    
    init(id: UUID = UUID(), name: String, nameEn: String, hp: Int, damage: Int, defense: Int = 0, type: EnemyType, isElite: Bool = false) {
        self.id = id
        self.name = name
        self.nameEn = nameEn
        self.hp = hp
        self.maxHp = hp
        self.baseDamage = damage
        self.currentDamage = damage
        self.defense = defense
        self.type = type
        self.isElite = isElite
        self.intent = .attack(damage: damage)
    }
    
    // Initializer for phase bosses with scaling
    init(type: EnemyType, wave: Int, phase: Int = 1, difficulty: GameDifficulty = .normal) {
        let phaseScaling: Double = 0.15 * Double(phase - 1)
        let difficultyMultiplier: Double = difficulty == .hard ? 1.5 : 1.0
        
        var baseHp: Int
        var baseDamage: Int
        var name: String
        var nameEn: String
        var defense: Int
        
        switch type {
        case .boss:
            baseHp = Int(Double(80 + wave * 10) * (1 + phaseScaling) * difficultyMultiplier)
            baseDamage = Int(Double(12 + wave) * (1 + phaseScaling) * difficultyMultiplier)
            defense = 5 + phase * 2
            name = "Jefe Fase \(phase)"
            nameEn = "Phase \(phase) Boss"
        case .finalBoss:
            baseHp = Int(Double(200) * difficultyMultiplier)
            baseDamage = Int(Double(25) * difficultyMultiplier)
            defense = 15
            name = "Señor de las Sombras"
            nameEn = "Lord of Shadows"
        default:
            baseHp = 50
            baseDamage = 10
            name = "Enemigo"
            nameEn = "Enemy"
            defense = 0
        }
        
        self.id = UUID()
        self.name = name
        self.nameEn = nameEn
        self.hp = baseHp
        self.maxHp = baseHp
        self.baseDamage = baseDamage
        self.currentDamage = baseDamage
        self.defense = defense
        self.type = type
        self.isElite = type == .boss || type == .finalBoss
        self.intent = .attack(damage: baseDamage)
    }
    
    mutating func takeDamage(_ damage: Int) -> Int {
        let actualDamage = max(1, damage - defense)
        hp = max(0, hp - actualDamage)
        return actualDamage
    }
    
    mutating func applyPoison(_ damage: Int, turns: Int) {
        isPoisoned = true
        poisonDamage = damage
        poisonTurns = turns
    }
    
    mutating func processPoison() {
        if isPoisoned && poisonTurns > 0 {
            hp = max(0, hp - poisonDamage)
            poisonTurns -= 1
            if poisonTurns <= 0 { isPoisoned = false }
        }
    }
    
    // Generate intelligent intent based on enemy type
    mutating func generateIntent(playerHP: Int, playerBlock: Int, otherEnemiesCount: Int) {
        let roll = Int.random(in: 1...100)
        
        switch type {
        case .basic:
            // 85% attack, 15% defend
            if roll <= 85 {
                intent = .attack(damage: currentDamage)
            } else {
                intent = .defend(block: baseDamage)
            }
            
        case .fast:
            // 70% double attack, 30% strong attack
            if roll <= 70 {
                intent = .attackTwice(damage: currentDamage)
            } else {
                intent = .attack(damage: currentDamage + 3)
            }
            
        case .tank:
            // 60% defend, 40% attack
            if roll <= 60 {
                intent = .defend(block: baseDamage + 5)
            } else {
                intent = .attack(damage: currentDamage)
            }
            
        case .boss:
            // Special boss abilities
            if roll <= 40 {
                intent = .attack(damage: currentDamage + 10)
            } else if roll <= 70 {
                intent = .buff
            } else if roll <= 90 {
                intent = .debuff
            } else {
                intent = .heal(amount: 15)
            }
            
        case .finalBoss:
            // Señor de las Sombras - more aggressive
            if roll <= 50 {
                intent = .attack(damage: currentDamage + 15)
            } else if roll <= 75 {
                intent = .attackTwice(damage: currentDamage + 8)
            } else if roll <= 90 {
                intent = .debuff
            } else {
                intent = .buff
            }
            
        case .scout:
            // Attacks if player is low HP, otherwise scouts (debuff)
            if playerHP < 20 && roll <= 70 {
                intent = .attack(damage: currentDamage + 5)
            } else {
                intent = .debuff
            }
            
        case .mage:
            // 50% attack, 30% debuff, 20% defend
            if roll <= 50 {
                intent = .attack(damage: currentDamage + 8)
            } else if roll <= 80 {
                intent = .debuff
            } else {
                intent = .defend(block: baseDamage)
            }
            
        case .healer:
            // Only attacks if alone, otherwise heals
            if otherEnemiesCount == 0 || roll > 60 {
                intent = .attack(damage: currentDamage)
            } else {
                intent = .heal(amount: 20)
            }
            
        case .swarm:
            // Many small attacks
            intent = .attackTwice(damage: currentDamage)
        }
    }
    
    var isDead: Bool { hp <= 0 }
}

// MARK: - Enemy Generation
extension Enemy {
    static func generate(for wave: Int, phase: Int = 1, difficulty: GameDifficulty = .normal) -> [Enemy] {
        let phaseScaling: Double = 0.15 * Double(phase - 1)
        let difficultyMultiplier: Double = difficulty == .hard ? 1.5 : 1.0
        
        let count = min(2 + wave / 2, 6)
        var enemies: [Enemy] = []
        
        for i in 0..<count {
            var enemy: Enemy
            
            // Boss wave every 5 (but handled by GameModel now)
            if wave > 7 && Int.random(in: 0...10) > 8 {
                // Rare elite enemy - scaled by phase
                enemy = createElite(wave: wave, phase: phase, difficulty: difficulty)
            } else {
                // Normal enemy based on wave and phase
                enemy = createNormalEnemy(wave: wave, phase: phase, difficulty: difficulty)
            }
            
            enemies.append(enemy)
        }
        
        return enemies
    }
    
    static func createBoss(wave: Int, phase: Int, difficulty: GameDifficulty) -> Enemy {
        return Enemy(type: .boss, wave: wave, phase: phase, difficulty: difficulty)
    }
    
    static func createElite(wave: Int, phase: Int, difficulty: GameDifficulty) -> Enemy {
        let types: [EnemyType] = [.scout, .mage, .healer]
        let type = types.randomElement()!
        
        let phaseScaling: Double = 0.15 * Double(phase - 1)
        let difficultyMultiplier: Double = difficulty == .hard ? 1.5 : 1.0
        
        switch type {
        case .scout:
            return Enemy(
                name: "Explorador", nameEn: "Scout",
                hp: Int(Double(25 + wave * 2) * (1 + phaseScaling) * difficultyMultiplier),
                damage: Int(Double(8 + wave) * (1 + phaseScaling) * difficultyMultiplier),
                type: .scout,
                isElite: true
            )
        case .mage:
            return Enemy(
                name: "Mago Oscuro", nameEn: "Dark Mage",
                hp: Int(Double(30 + wave * 2) * (1 + phaseScaling) * difficultyMultiplier),
                damage: Int(Double(12 + wave) * (1 + phaseScaling) * difficultyMultiplier),
                type: .mage,
                isElite: true
            )
        case .healer:
            return Enemy(
                name: "Sanador", nameEn: "Healer",
                hp: 35 + wave * 2,
                damage: 6 + wave,
                type: .healer,
                isElite: true
            )
        default:
            return createNormalEnemy(wave: wave, index: 0)
        }
    }
    
    static func createNormalEnemy(wave: Int, index: Int = 0, phase: Int = 1, difficulty: GameDifficulty = .normal) -> Enemy {
        let phaseScaling: Double = 0.15 * Double(phase - 1)
        let difficultyMultiplier: Double = difficulty == .hard ? 1.5 : 1.0
        
        let roll = Int.random(in: 1...100)
        
        // Scale wave based on phase - higher phases can spawn stronger enemies earlier
        let effectiveWave = wave + (phase - 1) * 2
        
        if effectiveWave <= 2 {
            // Early waves: mostly basics
            return Enemy(
                name: "Zombi", nameEn: "Zombie",
                hp: Int(Double(20 + wave * 2) * (1 + phaseScaling) * difficultyMultiplier),
                damage: Int(Double(5 + wave) * (1 + phaseScaling) * difficultyMultiplier),
                type: .basic
            )
        } else if effectiveWave <= 4 {
            // Introduce fast enemies
            if roll <= 70 {
                return Enemy(
                    name: "Zombi", nameEn: "Zombie",
                    hp: Int(Double(22 + wave * 2) * (1 + phaseScaling) * difficultyMultiplier),
                    damage: Int(Double(5 + wave) * (1 + phaseScaling) * difficultyMultiplier),
                    type: .basic
                )
            } else {
                return Enemy(
                    name: "Murciélago", nameEn: "Bat",
                    hp: Int(Double(15 + wave * 2) * (1 + phaseScaling) * difficultyMultiplier),
                    damage: Int(Double(6 + wave) * (1 + phaseScaling) * difficultyMultiplier),
                    type: .fast
                )
            }
        } else if effectiveWave <= 6 {
            // Introduce tank
            if roll <= 50 {
                return Enemy(
                    name: "Zombi", nameEn: "Zombie",
                    hp: Int(Double(25 + wave * 2) * (1 + phaseScaling) * difficultyMultiplier),
                    damage: Int(Double(6 + wave) * (1 + phaseScaling) * difficultyMultiplier),
                    type: .basic
                )
            } else if roll <= 75 {
                return Enemy(
                    name: "Murciélago", nameEn: "Bat",
                    hp: Int(Double(18 + wave * 2) * (1 + phaseScaling) * difficultyMultiplier),
                    damage: Int(Double(7 + wave) * (1 + phaseScaling) * difficultyMultiplier),
                    type: .fast
                )
            } else {
                return Enemy(
                    name: "Golem", nameEn: "Golem",
                    hp: Int(Double(40 + wave * 3) * (1 + phaseScaling) * difficultyMultiplier),
                    damage: Int(Double(8 + wave) * (1 + phaseScaling) * difficultyMultiplier),
                    defense: Int(Double(3 + wave / 2) * (1 + phaseScaling)),
                    type: .tank
                )
            }
        } else {
            // Later waves: more variety, including enemies from higher phases
            if roll <= 25 {
                return Enemy(
                    name: "Zombi", nameEn: "Zombie",
                    hp: Int(Double(28 + wave * 2) * (1 + phaseScaling) * difficultyMultiplier),
                    damage: Int(Double(7 + wave) * (1 + phaseScaling) * difficultyMultiplier),
                    type: .basic
                )
            } else if roll <= 45 {
                return Enemy(
                    name: "Murciélago", nameEn: "Bat",
                    hp: Int(Double(20 + wave * 2) * (1 + phaseScaling) * difficultyMultiplier),
                    damage: Int(Double(8 + wave) * (1 + phaseScaling) * difficultyMultiplier),
                    type: .fast
                )
            } else if roll <= 60 {
                return Enemy(
                    name: "Golem", nameEn: "Golem",
                    hp: Int(Double(45 + wave * 3) * (1 + phaseScaling) * difficultyMultiplier),
                    damage: Int(Double(10 + wave) * (1 + phaseScaling) * difficultyMultiplier),
                    defense: Int(Double(4 + wave / 2) * (1 + phaseScaling)),
                    type: .tank
                )
            } else if roll <= 75 {
                return Enemy(
                    name: "Enjambre", nameEn: "Swarm",
                    hp: Int(Double(30 + wave * 2) * (1 + phaseScaling) * difficultyMultiplier),
                    damage: Int(Double(5 + wave) * (1 + phaseScaling) * difficultyMultiplier),
                    type: .swarm
                )
            } else if roll <= 90 {
                return Enemy(
                    name: "Mago", nameEn: "Mage",
                    hp: Int(Double(25 + wave * 2) * (1 + phaseScaling) * difficultyMultiplier),
                    damage: Int(Double(12 + wave) * (1 + phaseScaling) * difficultyMultiplier),
                    type: .mage
                )
            } else {
                return Enemy(
                    name: "Sanador", nameEn: "Healer",
                    hp: Int(Double(35 + wave * 2) * (1 + phaseScaling) * difficultyMultiplier),
                    damage: Int(Double(8 + wave) * (1 + phaseScaling) * difficultyMultiplier),
                    type: .healer
                )
            }
        }
    }
}
