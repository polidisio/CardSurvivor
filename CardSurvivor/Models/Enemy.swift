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
        case boss       // Jefe
        case scout      // Explorador - attacks weakest
        case mage       // Mago - uses magic
        case healer     // Sanador - heals enemies
        case swarm      // Swarm - many weak attacks
    }
    
    var icon: String {
        switch type {
        case .basic: return "skull"
        case .fast: return "bolt.fill"
        case .tank: return "shield.fill"
        case .boss: return "crown.fill"
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
    static func generate(for wave: Int) -> [Enemy] {
        let count = min(2 + wave / 2, 6)
        var enemies: [Enemy] = []
        
        for i in 0..<count {
            var enemy: Enemy
            
            // Boss wave every 5
            if wave % 5 == 0 && i == 0 {
                enemy = createBoss(wave: wave)
            } else if wave > 7 && Int.random(in: 0...10) > 8 {
                // Rare elite enemy
                enemy = createElite(wave: wave)
            } else {
                // Normal enemy based on wave
                enemy = createNormalEnemy(wave: wave, index: i)
            }
            
            enemies.append(enemy)
        }
        
        return enemies
    }
    
    static func createBoss(wave: Int) -> Enemy {
        Enemy(
            name: "Demonio Alfa", nameEn: "Alpha Demon",
            hp: 80 + wave * 10,
            damage: 20 + wave * 2,
            defense: 5 + wave,
            type: .boss
        )
    }
    
    static func createElite(wave: Int) -> Enemy {
        let types: [EnemyType] = [.scout, .mage, .healer]
        let type = types.randomElement()!
        
        switch type {
        case .scout:
            return Enemy(
                name: "Explorador", nameEn: "Scout",
                hp: 25 + wave * 2,
                damage: 8 + wave,
                type: .scout,
                isElite: true
            )
        case .mage:
            return Enemy(
                name: "Mago Oscur", nameEn: "Dark Mage",
                hp: 30 + wave * 2,
                damage: 12 + wave,
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
    
    static func createNormalEnemy(wave: Int, index: Int) -> Enemy {
        let roll = Int.random(in: 1...100)
        
        if wave <= 2 {
            // Early waves: mostly basics
            return Enemy(
                name: "Zombi", nameEn: "Zombie",
                hp: 20 + wave * 2,
                damage: 5 + wave,
                type: .basic
            )
        } else if wave <= 4 {
            // Introduce fast enemies
            if roll <= 70 {
                return Enemy(
                    name: "Zombi", nameEn: "Zombie",
                    hp: 22 + wave * 2,
                    damage: 5 + wave,
                    type: .basic
                )
            } else {
                return Enemy(
                    name: "Murciélago", nameEn: "Bat",
                    hp: 15 + wave * 2,
                    damage: 6 + wave,
                    type: .fast
                )
            }
        } else if wave <= 6 {
            // Introduce tank
            if roll <= 50 {
                return Enemy(
                    name: "Zombi", nameEn: "Zombie",
                    hp: 25 + wave * 2,
                    damage: 6 + wave,
                    type: .basic
                )
            } else if roll <= 75 {
                return Enemy(
                    name: "Murciélago", nameEn: "Bat",
                    hp: 18 + wave * 2,
                    damage: 7 + wave,
                    type: .fast
                )
            } else {
                return Enemy(
                    name: "Golem", nameEn: "Golem",
                    hp: 40 + wave * 3,
                    damage: 8 + wave,
                    defense: 3 + wave / 2,
                    type: .tank
                )
            }
        } else {
            // Later waves: more variety
            if roll <= 30 {
                return Enemy(
                    name: "Zombi", nameEn: "Zombie",
                    hp: 28 + wave * 2,
                    damage: 7 + wave,
                    type: .basic
                )
            } else if roll <= 50 {
                return Enemy(
                    name: "Murciélago", nameEn: "Bat",
                    hp: 20 + wave * 2,
                    damage: 8 + wave,
                    type: .fast
                )
            } else if roll <= 65 {
                return Enemy(
                    name: "Golem", nameEn: "Golem",
                    hp: 45 + wave * 3,
                    damage: 10 + wave,
                    defense: 4 + wave / 2,
                    type: .tank
                )
            } else if roll <= 80 {
                return Enemy(
                    name: "Enjambre", nameEn: "Swarm",
                    hp: 30 + wave * 2,
                    damage: 5 + wave,
                    type: .swarm
                )
            } else {
                return Enemy(
                    name: "Mago", nameEn: "Mage",
                    hp: 25 + wave * 2,
                    damage: 12 + wave,
                    type: .mage
                )
            }
        }
    }
}
