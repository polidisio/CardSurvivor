import SwiftUI

struct ContentView: View {
    @StateObject private var game = GameModel()
    
    var body: some View {
        ZStack {
            Color(hex: "1C1C1E").ignoresSafeArea()
            
            switch game.state {
            case .mainMenu: MainMenuView(game: game)
            case .classSelection: ClassSelectionView(game: game)
            case .classDetails: ClassDetailsView(game: game)
            case .profile: ProfileView(game: game)
            case .settings: SettingsView(game: game)
            case .playing, .playerTurn, .enemyTurn: GameView(game: game)
            case .shop: ShopView(game: game)
            case .relicShop: RelicShopView(game: game)
            case .waveComplete: WaveCompleteView(game: game)
            case .phaseComplete: PhaseCompleteView(game: game)
            case .bossReward: BossRewardView(game: game)
            case .gameOver: GameOverView(game: game)
            }
        }
    }
}

struct MainMenuView: View {
    @ObservedObject var game: GameModel
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            VStack(spacing: 10) {
                Text("CARD").font(.system(size: 48, weight: .bold)).foregroundColor(Color(hex: "BF5AF2"))
                Text("SURVIVOR").font(.system(size: 48, weight: .bold)).foregroundColor(.white)
            }
            Spacer()
            VStack(spacing: 15) {
                Button(action: { game.state = .classSelection }) {
                    HStack { Image(systemName: "play.fill").font(.title2); Text("JUGAR").font(.title2).fontWeight(.bold) }
                    .foregroundColor(.white).frame(width: 220, height: 60).background(Color(hex: "BF5AF2")).cornerRadius(15)
                }
                Button(action: { game.state = .profile }) {
                    HStack { Image(systemName: "person.circle.fill").font(.title2); Text("PERFIL").font(.title2).fontWeight(.bold) }
                    .foregroundColor(.white).frame(width: 220, height: 60).background(Color(hex: "2C2C2E")).cornerRadius(15)
                }
                Button(action: { game.state = .settings }) {
                    HStack { Image(systemName: "gearshape.fill").font(.title2); Text("AJUSTES").font(.title2).fontWeight(.bold) }
                    .foregroundColor(.white).frame(width: 220, height: 60).background(Color(hex: "2C2C2E")).cornerRadius(15)
                }
            }
            Spacer()
            HStack { Image(systemName: "diamond.fill").foregroundColor(Color(hex: "00D4FF")); Text("\(game.progression.gems)").foregroundColor(Color(hex: "00D4FF")).font(.headline) }
            .padding(.horizontal, 16).padding(.vertical, 8).background(Color(hex: "00D4FF").opacity(0.2)).cornerRadius(20)
            Spacer()
        }
        .background(Color(hex: "1C1C1E"))
    }
}

struct SettingsView: View {
    @ObservedObject var game: GameModel
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { game.state = .mainMenu }) { Image(systemName: "chevron.left").foregroundColor(.white) }
                Spacer()
                Text("AJUSTES").font(.headline).foregroundColor(.white)
                Spacer()
            }
            .padding().background(Color(hex: "2C2C2E"))
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("ACERCA DE").font(.headline).foregroundColor(.gray)
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Card Survivor").foregroundColor(.white)
                            Text("Versión 1.0.0").foregroundColor(.gray).font(.caption)
                        }
                        .padding().background(Color(hex: "2C2C2E")).cornerRadius(10)
                    }
                    .padding()
                }
            }
        }
        .background(Color(hex: "1C1C1E"))
    }
}

struct ClassSelectionView: View {
    @ObservedObject var game: GameModel
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: { game.state = .mainMenu }) { Image(systemName: "chevron.left").foregroundColor(.white) }
                Spacer()
                Text("SELECCIONA CLASE").font(.headline).foregroundColor(.white)
                Spacer()
            }
            .padding().background(Color(hex: "2C2C2E"))
            
            ScrollView {
                VStack(spacing: 15) {
                    Button(action: {
                        game.selectedClassForDetails = .warrior
                        game.state = .classDetails
                    }) {
                        classCard("Guerrero", hp: PlayerClass.warrior.baseHP, energy: PlayerClass.warrior.baseEnergy)
                    }
                    Button(action: {
                        game.selectedClassForDetails = .mage
                        game.state = .classDetails
                    }) {
                        classCard("Mago", hp: PlayerClass.mage.baseHP, energy: PlayerClass.mage.baseEnergy)
                    }
                    Button(action: {
                        game.selectedClassForDetails = .rogue
                        game.state = .classDetails
                    }) {
                        classCard("Pícaro", hp: PlayerClass.rogue.baseHP, energy: PlayerClass.rogue.baseEnergy)
                    }
                    Button(action: {
                        game.selectedClassForDetails = .paladin
                        game.state = .classDetails
                    }) {
                        classCard("Paladín", hp: PlayerClass.paladin.baseHP, energy: PlayerClass.paladin.baseEnergy)
                    }
                }
                .padding()
            }
        }
        .background(Color(hex: "1C1C1E"))
    }
    
    func classCard(_ name: String, hp: Int, energy: Int) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(name).font(.headline).foregroundColor(.white)
                Text("HP: \(hp) | Energía: \(energy)").font(.caption).foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundColor(.gray)
        }
        .padding().background(Color(hex: "2C2C2E")).cornerRadius(10)
    }
}

struct ClassDetailsView: View {
    @ObservedObject var game: GameModel
    
    private var playerClass: PlayerClass {
        game.selectedClassForDetails ?? .warrior
    }
    
    private var startingDeck: [Card] {
        Player.createStartingDeck(for: playerClass)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { game.state = .classSelection }) { Image(systemName: "chevron.left").foregroundColor(.white) }
                Spacer()
                Text(playerClass.name).font(.headline).foregroundColor(.white)
                Spacer()
            }
            .padding().background(Color(hex: "2C2C2E"))
            
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        Image(systemName: playerClass.icon).font(.system(size: 50)).foregroundColor(Color(hex: "BF5AF2"))
                        VStack(alignment: .leading) {
                            Text(playerClass.name).font(.title).fontWeight(.bold).foregroundColor(.white)
                            Text(playerClass.description).font(.caption).foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding().background(Color(hex: "2C2C2E")).cornerRadius(10)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("ESTADÍSTICAS").font(.headline).foregroundColor(.gray)
                        HStack {
                            statItem("HP", "\(playerClass.baseHP)", "heart.fill", .red)
                            statItem("ENERGÍA", "\(playerClass.baseEnergy)", "bolt.fill", .yellow)
                            statItem("DAÑO", "\(playerClass.baseDamage)", "flame.fill", .orange)
                        }
                    }
                    .padding().background(Color(hex: "2C2C2E")).cornerRadius(10)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("HABILIDAD PASIVA").font(.headline).foregroundColor(.gray)
                        HStack {
                            Image(systemName: "sparkles").foregroundColor(Color(hex: "BF5AF2"))
                            Text(playerClass.passiveAbility).foregroundColor(.white)
                        }
                    }
                    .padding().background(Color(hex: "2C2C2E")).cornerRadius(10)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("MAZO INICIAL (\(startingDeck.count) cartas)").font(.headline).foregroundColor(.gray)
                        ForEach(startingDeck, id: \.id) { card in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(card.name).font(.subheadline).foregroundColor(.white)
                                    Text("\(card.type == .attack ? "Ataque" : card.type == .defense ? "Defensa" : card.type == .power ? "Poder" : card.type == .draw ? "Robar" : "Especial") - \(card.cost) energía").font(.caption2).foregroundColor(.gray)
                                }
                                Spacer()
                                Text("\(card.value)").font(.headline).foregroundColor(card.type == .attack ? .red : card.type == .defense ? .blue : .green)
                            }
                        }
                    }
                    .padding().background(Color(hex: "2C2C2E")).cornerRadius(10)
                    
                    VStack(spacing: 15) {
                        Button(action: {
                            game.selectClass(playerClass)
                            game.startNewGame()
                        }) {
                            HStack { Image(systemName: "play.fill"); Text("JUGAR") }
                            .font(.title3).fontWeight(.bold).foregroundColor(.white).frame(maxWidth: .infinity).padding().background(Color(hex: "BF5AF2")).cornerRadius(15)
                        }
                    }
                    .padding(.top, 10)
                }
                .padding()
            }
        }
        .background(Color(hex: "1C1C1E"))
    }
    
    func statItem(_ title: String, _ value: String, _ icon: String, _ color: Color) -> some View {
        VStack(spacing: 5) {
            Image(systemName: icon).foregroundColor(color)
            Text(value).font(.headline).foregroundColor(.white)
            Text(title).font(.caption2).foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ProfileView: View {
    @ObservedObject var game: GameModel
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: { game.state = .mainMenu }) { Image(systemName: "chevron.left").foregroundColor(.white) }
                Spacer()
                Text("PERFIL").font(.headline).foregroundColor(.white)
                Spacer()
            }
            .padding().background(Color(hex: "2C2C2E"))
            
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 10) {
                        Text("Gemas").font(.headline).foregroundColor(.gray)
                        Text("\(game.progression.gems)").font(.largeTitle).foregroundColor(Color(hex: "00D4FF"))
                    }
                    .padding().background(Color(hex: "2C2C2E")).cornerRadius(10)
                    
                    VStack(spacing: 10) {
                        Text("Mejor Puntuación").font(.headline).foregroundColor(.gray)
                        Text("\(game.highScore)").font(.largeTitle).foregroundColor(.yellow)
                    }
                    .padding().background(Color(hex: "2C2C2E")).cornerRadius(10)
                }
                .padding()
            }
        }
        .background(Color(hex: "1C1C1E"))
    }
}

struct GameView: View {
    @ObservedObject var game: GameModel
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading) { 
                    HStack(spacing: 8) { 
                        Image(systemName: game.player.playerClass.icon).foregroundColor(classColor); 
                        Text(game.isBossWave ? "FASE \(game.currentPhase) - BOSS" : "Fase \(game.currentPhase) - Oleada \(game.wave)/5").font(.headline).foregroundColor(game.isBossWave ? .red : .white) 
                    }; 
                    Text(game.state == .playerTurn ? "Tu turno" : "Enemigos").font(.caption).foregroundColor(game.state == .playerTurn ? Color(hex: "30D158") : Color(hex: "FF453A")) 
                }
                Spacer()
                if !game.progression.equippedRelics.isEmpty { 
                    HStack(spacing: 2) { 
                        ForEach(game.progression.equippedRelics.prefix(3), id: \.self) { relicId in 
                            if let relic = Relic.relic(byId: relicId) { 
                                Image(systemName: relic.icon).font(.caption2).foregroundColor(Color(hex: relic.rarity.color)) 
                            } 
                        } 
                    }.padding(.horizontal, 8).padding(.vertical, 4).background(Color(hex: "2C2C2E")).cornerRadius(8) 
                }
                Spacer()
                VStack(alignment: .trailing) { 
                    HStack { Image(systemName: "dollarsign.circle.fill").foregroundColor(Color(hex: "FFD60A")); Text("\(game.player.gold)").foregroundColor(Color(hex: "FFD60A")) }; 
                    Text("Score: \(game.score)").foregroundColor(.white).font(.caption) 
                }
            }.padding().background(Color(hex: "2C2C2E"))
            
            ZStack {
                VStack {
                    if game.state == .enemyTurn { Text("ENEMIGOS ATACANDO...").font(.headline).foregroundColor(.red).padding(.bottom, 10) }
                    if game.enemies.isEmpty { 
                        VStack { 
                            Image(systemName: "checkmark.circle.fill").font(.system(size: 60)).foregroundColor(Color(hex: "30D158")); 
                            Text("Victoria!").font(.title2).foregroundColor(.white) 
                        } 
                    }
                    else { 
                        HStack(spacing: 15) { 
                            ForEach(game.enemies) { enemy in 
                                EnemyView(enemy: enemy, isSelected: game.selectedEnemy?.id == enemy.id, isAttacking: game.state == .enemyTurn).onTapGesture { 
                                    if game.state == .playerTurn && game.selectedCard?.type == .attack { 
                                        game.selectEnemy(enemy) 
                                    } 
                                } 
                            } 
                        } 
                    }
                }
                if game.showMessage { 
                    VStack { 
                        Spacer(); 
                        Text(game.message).font(.title2).fontWeight(.bold).foregroundColor(.white).padding().background(Color.black.opacity(0.9)).cornerRadius(10).padding(.bottom, 50) 
                    }.transition(.move(edge: .bottom).combined(with: .opacity)) 
                }
            }.frame(maxHeight: .infinity).background(Color(hex: "1C1C1E")).animation(.easeInOut(duration: 0.3), value: game.state)
            
            HStack {
                HStack(spacing: 5) { Image(systemName: "heart.fill").foregroundColor(.red); Text("\(game.player.hp)/\(game.player.maxHp)").foregroundColor(.white).fontWeight(.bold) }
                if game.player.level > 1 { Text("Nivel \(game.player.level)").font(.caption2).foregroundColor(classColor) }
                Spacer()
                if game.playerBlock > 0 { 
                    HStack(spacing: 5) { Image(systemName: "shield.fill").foregroundColor(Color(hex: "0A84FF")); Text("\(game.playerBlock)").foregroundColor(Color(hex: "0A84FF")) }.padding(.horizontal, 8).padding(.vertical, 4).background(Color(hex: "0A84FF").opacity(0.2)).cornerRadius(8) 
                }
                Spacer()
                HStack(spacing: 4) { 
                    ForEach(0..<game.player.maxEnergy, id: \.self) { index in 
                        ZStack { 
                            Circle().fill(index < game.player.energy ? Color(hex: "FFD60A") : Color.gray.opacity(0.3)).frame(width: 28, height: 28); 
                            Text("\(index + 1)").font(.caption).fontWeight(.bold).foregroundColor(index < game.player.energy ? .black : .gray) 
                        } 
                    } 
                }
                Spacer()
                if game.player.damageBuff > 0 { Text("+\(game.player.damageBuff)").font(.caption).foregroundColor(.red).padding(.horizontal, 8).padding(.vertical, 4).background(Color.red.opacity(0.2)).cornerRadius(8) }
                Button(action: { game.endPlayerTurn() }) { 
                    Text(game.state == .enemyTurn ? "..." : "Fin").font(.caption).fontWeight(.bold).padding(.horizontal, 12).padding(.vertical, 8).background(game.state == .enemyTurn ? Color.gray : Color(hex: "FF9F0A")).foregroundColor(.white).cornerRadius(8) 
                }.disabled(game.state == .enemyTurn)
            }.padding().background(Color(hex: "2C2C2E"))
            
            VStack(spacing: 8) {
                if game.state == .playerTurn { 
                    HStack { 
                        Image(systemName: "info.circle").foregroundColor(.gray); 
                        Text(game.selectedCard != nil ? "Toca enemigo para \(game.selectedCard!.name)" : "Toca una carta").font(.caption).foregroundColor(.gray) 
                    } 
                }
                ScrollView(.horizontal, showsIndicators: false) { 
                    HStack(spacing: 12) { 
                        ForEach(game.player.hand) { card in 
                            CardView(card: card, isSelected: game.selectedCard?.id == card.id, canPlay: game.state == .playerTurn && game.player.energy >= card.cost).onTapGesture { 
                                if game.state == .playerTurn { game.selectCard(card) } 
                            }.opacity(game.state == .playerTurn && game.player.energy >= card.cost ? 1 : 0.5) 
                        } 
                    }.padding(.horizontal) 
                }
            }.frame(height: 150).background(Color(hex: "2C2C2E"))
        }
    }
    
    var classColor: Color {
        switch game.player.playerClass { 
        case .warrior: return .red; 
        case .mage: return .blue; 
        case .rogue: return .green; 
        case .paladin: return .yellow 
        }
    }
}

struct RelicShopView: View {
    @ObservedObject var game: GameModel
    
    var body: some View {
        VStack(spacing: 20) {
            HStack { 
                Text("RELICARIOS").font(.largeTitle).fontWeight(.bold).foregroundColor(.white); 
                Spacer(); 
                HStack { Image(systemName: "diamond.fill").foregroundColor(Color(hex: "00D4FF")); Text("\(game.progression.gems)").foregroundColor(Color(hex: "00D4FF")).font(.title2) } 
            }.padding()
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) { 
                    ForEach(game.availableRelics) { relic in 
                        VStack(spacing: 8) {
                            Image(systemName: relic.icon).font(.system(size: 30)).foregroundColor(Color(hex: relic.rarity.color))
                            Text(relic.name).font(.caption).fontWeight(.bold).foregroundColor(.white)
                            Text("+\(relic.value) \(relic.description)").font(.caption2).foregroundColor(.gray).lineLimit(2)
                            Text("\(RelicShop.getRelicPrice(for: relic.rarity))").font(.caption).foregroundColor(Color(hex: "00D4FF"))
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "2C2C2E"))
                        .cornerRadius(10)
                        .onTapGesture {
                            game.buyRelic(relic)
                        }
                    } 
                }.padding()
            }
            
            Spacer()
            Button(action: { game.startNextWave() }) { 
                Text("Continuar").font(.title2).fontWeight(.bold).foregroundColor(.white).frame(maxWidth: .infinity).padding().background(Color(hex: "BF5AF2")).cornerRadius(15) 
            }.padding()
        }.background(Color(hex: "1C1C1E"))
    }
}

struct ShopView: View {
    @ObservedObject var game: GameModel
    
    var body: some View {
        VStack(spacing: 20) {
            HStack { 
                Text("TIENDA").font(.largeTitle).fontWeight(.bold).foregroundColor(.white); 
                Spacer(); 
                HStack { Image(systemName: "dollarsign.circle.fill").foregroundColor(Color(hex: "FFD60A")); Text("\(game.player.gold)").foregroundColor(Color(hex: "FFD60A")).font(.title2) } 
            }.padding()
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) { 
                    ForEach(game.shopCards) { card in 
                        CardView(card: card, showPrice: true, price: card.cost * 15, canPlay: game.player.gold >= card.cost * 15).onTapGesture { 
                            game.buyCard(card) 
                        } 
                    } 
                }.padding()
            }
            
            Spacer()
            Button(action: { game.startNextWave() }) { 
                Text("Siguiente Oleada").font(.title2).fontWeight(.bold).foregroundColor(.white).frame(maxWidth: .infinity).padding().background(Color(hex: "BF5AF2")).cornerRadius(15) 
            }.padding()
        }.background(Color(hex: "1C1C1E"))
    }
}

struct WaveCompleteView: View {
    @ObservedObject var game: GameModel
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            Text("OLEADA \(game.wave) COMPLETA!").font(.largeTitle).fontWeight(.bold).foregroundColor(Color(hex: "FFD60A"))
            VStack(spacing: 10) { 
                Text("Score: \(game.score)").font(.title).foregroundColor(.white); 
                Text("Oro: \(game.player.gold)").font(.title2).foregroundColor(Color(hex: "FFD60A")); 
                Text("Nivel: \(game.player.level)").font(.headline).foregroundColor(classColor) 
            }
            VStack(spacing: 5) { 
                Text("+ \(game.gemsEarned)").font(.title).foregroundColor(Color(hex: "00D4FF")); 
                Text("Gemas ganadas").font(.caption).foregroundColor(.gray) 
            }.padding().background(Color(hex: "00D4FF").opacity(0.1)).cornerRadius(10)
            Spacer()
            Button(action: { game.claimGems(); game.startNextWave() }) { 
                Text("Continuar").font(.title2).fontWeight(.bold).foregroundColor(.white).frame(width: 200, height: 50).background(Color(hex: "BF5AF2")).cornerRadius(15) 
            }
            Spacer()
        }.frame(maxWidth: .infinity, maxHeight: .infinity).background(Color(hex: "1C1C1E"))
    }
    
    var classColor: Color { 
        switch game.player.playerClass { 
        case .warrior: return .red; 
        case .mage: return .blue; 
        case .rogue: return .green; 
        case .paladin: return .yellow 
        } 
    }
}

struct GameOverView: View {
    @ObservedObject var game: GameModel
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            Text("GAME OVER").font(.system(size: 48, weight: .bold)).foregroundColor(.red)
            VStack(spacing: 10) { 
                Text("Oleadas: \(game.wave)").font(.title).foregroundColor(.white); 
                Text("Score: \(game.score)").font(.title2).foregroundColor(Color(hex: "BF5AF2")); 
                if game.score >= game.highScore { Text("NUEVA MEJOR PUNTUACIÓN!").foregroundColor(Color(hex: "FFD60A")) } 
            }
            VStack(spacing: 5) { 
                Text("+ \(game.gemsEarned)").font(.title).foregroundColor(Color(hex: "00D4FF")); 
                Text("Gemas ganadas").font(.caption).foregroundColor(.gray) 
            }.padding().background(Color(hex: "00D4FF").opacity(0.1)).cornerRadius(10)
            Spacer()
            VStack(spacing: 15) {
                Button(action: { game.claimGems(); game.startNewGame() }) { 
                    Text("Jugar de nuevo").font(.title2).fontWeight(.bold).foregroundColor(.white).frame(width: 200, height: 50).background(Color(hex: "BF5AF2")).cornerRadius(15) 
                }
                Button(action: { game.claimGems(); game.state = .profile }) { 
                    Text("Perfil").font(.title2).foregroundColor(.white).frame(width: 200, height: 50).background(Color.gray.opacity(0.3)).cornerRadius(15) 
                }
                Button(action: { game.claimGems(); game.state = .classSelection }) { 
                    Text("Cambiar Clase").font(.title2).foregroundColor(.white).frame(width: 200, height: 50).background(Color.gray.opacity(0.3)).cornerRadius(15) 
                }
            }
            Spacer()
        }.frame(maxWidth: .infinity, maxHeight: .infinity).background(Color(hex: "1C1C1E"))
    }
}

struct CardView: View {
    let card: Card
    var isSelected: Bool = false
    var showPrice: Bool = false
    var price: Int = 0
    var canPlay: Bool = true
    
    var body: some View {
        VStack(spacing: 4) {
            HStack { Image(systemName: iconForCardType(card.type)).foregroundColor(cardColor).font(.caption); Spacer(); Text("\(card.cost)").font(.caption).fontWeight(.bold).foregroundColor(.white).padding(.horizontal, 6).padding(.vertical, 2).background(cardColor).cornerRadius(4) }
            Text(card.name).font(.caption).fontWeight(.bold).foregroundColor(.white).lineLimit(1)
            if card.value > 0 { Text("\(card.value)").font(.title).fontWeight(.bold).foregroundColor(cardColor) } else { Spacer().frame(height: 30) }
            Text(card.description).font(.caption2).foregroundColor(.gray).lineLimit(2).multilineTextAlignment(.center)
            if showPrice { Text("\(price)").font(.caption2).foregroundColor(Color(hex: "FFD60A")) }
        }
        .padding(10).frame(width: 110, height: 150).background(isSelected ? cardColor.opacity(0.3) : cardBackground).cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(isSelected ? cardColor : cardColor.opacity(0.5), lineWidth: isSelected ? 3 : 2))
        .scaleEffect(isSelected ? 1.05 : 1.0).animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    func iconForCardType(_ type: Card.CardType) -> String {
        switch type { 
        case .attack: return "bolt.fill"; 
        case .defense: return "shield.fill"; 
        case .power: return "star.fill"; 
        case .draw: return "arrow.down.circle.fill"; 
        case .special: return "sparkles" 
        }
    }
    
    var cardColor: Color {
        switch card.type { 
        case .attack: return Color(hex: "FF453A"); 
        case .defense: return Color(hex: "0A84FF"); 
        case .power: return Color(hex: "BF5AF2"); 
        case .draw: return Color(hex: "30D158"); 
        case .special: return Color(hex: "FFD60A") 
        }
    }
    
    var cardBackground: Color {
        switch card.rarity { 
        case .common: return Color(hex: "2C2C2E"); 
        case .uncommon: return Color(hex: "3C3C3E"); 
        case .rare: return Color(hex: "4C4C4E"); 
        case .epic: return Color(hex: "5C4C5E"); 
        case .legendary: return Color(hex: "FFD60A").opacity(0.3) 
        }
    }
}

struct EnemyView: View {
    let enemy: Enemy
    let isSelected: Bool
    var isAttacking: Bool = false
    
    var body: some View {
        VStack(spacing: 5) {
            ZStack { 
                if isAttacking { Circle().fill(Color.red.opacity(0.3)).frame(width: 60, height: 60) }; 
                Image(systemName: enemy.icon).font(.system(size: 40)).foregroundColor(enemyColor).scaleEffect(isAttacking ? 1.3 : 1.0) 
            }
            Text(enemy.name).font(.caption).fontWeight(.bold).foregroundColor(.white)
            VStack(spacing: 2) { 
                GeometryReader { geometry in 
                    ZStack(alignment: .leading) { 
                        Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 8).cornerRadius(4); 
                        Rectangle().fill(hpColor).frame(width: geometry.size.width * CGFloat(enemy.hp) / CGFloat(max(enemy.maxHp, 1)), height: 8).cornerRadius(4) 
                    } 
                }.frame(width: 70, height: 8); 
                Text("\(enemy.hp)/\(enemy.maxHp)").font(.caption2).foregroundColor(.white) 
            }
            intentBadge
            if enemy.isPoisoned { 
                HStack(spacing: 2) { 
                    Image(systemName: "flame.fill").font(.caption2).foregroundColor(.green); 
                    Text("\(enemy.poisonDamage)x\(enemy.poisonTurns)").font(.caption2).foregroundColor(.green) 
                } 
            }
        }.padding(12).background(isSelected ? Color.white.opacity(0.2) : Color(hex: "2C2C2E")).cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(isSelected ? Color.white : (isAttacking ? Color.red : Color.clear), lineWidth: isSelected ? 3 : 2))
    }
    
    @ViewBuilder
    var intentBadge: some View {
        switch enemy.intent {
        case .attack(let damage): 
            HStack(spacing: 4) { Image(systemName: "sword.fill").font(.caption2); Text("\(damage)").font(.caption2).fontWeight(.bold) }.foregroundColor(.red).padding(.horizontal, 8).padding(.vertical, 4).background(Color.red.opacity(0.2)).cornerRadius(8)
        case .attackTwice(let damage): 
            HStack(spacing: 4) { Image(systemName: "sword.fill").font(.caption2); Text("\(damage)x2").font(.caption2).fontWeight(.bold) }.foregroundColor(.red).padding(.horizontal, 8).padding(.vertical, 4).background(Color.red.opacity(0.2)).cornerRadius(8)
        case .defend(let block): 
            HStack(spacing: 4) { Image(systemName: "shield.fill").font(.caption2); Text("\(block)").font(.caption2).fontWeight(.bold) }.foregroundColor(Color(hex: "0A84FF")).padding(.horizontal, 8).padding(.vertical, 4).background(Color(hex: "0A84FF").opacity(0.2)).cornerRadius(8)
        case .buff: 
            HStack(spacing: 4) { Image(systemName: "arrow.up.circle.fill").font(.caption2); Text("BUFF").font(.caption2).fontWeight(.bold) }.foregroundColor(.purple).padding(.horizontal, 8).padding(.vertical, 4).background(Color.purple.opacity(0.2)).cornerRadius(8)
        case .debuff: 
            HStack(spacing: 4) { Image(systemName: "arrow.down.circle.fill").font(.caption2); Text("WEAK").font(.caption2).fontWeight(.bold) }.foregroundColor(.orange).padding(.horizontal, 8).padding(.vertical, 4).background(Color.orange.opacity(0.2)).cornerRadius(8)
        case .heal(let amount): 
            HStack(spacing: 4) { Image(systemName: "plus.circle.fill").font(.caption2); Text("+\(amount)").font(.caption2).fontWeight(.bold) }.foregroundColor(.green).padding(.horizontal, 8).padding(.vertical, 4).background(Color.green.opacity(0.2)).cornerRadius(8)
        case .summon: 
            HStack(spacing: 4) { Image(systemName: "plus.circle.fill").font(.caption2); Text("INVOCAR").font(.caption2).fontWeight(.bold) }.foregroundColor(.purple).padding(.horizontal, 8).padding(.vertical, 4).background(Color.purple.opacity(0.2)).cornerRadius(8)
        }
    }
    
    var enemyColor: Color { 
        switch enemy.type { 
        case .basic: return .gray; 
        case .fast: return .yellow; 
        case .tank: return .blue; 
        case .boss: return .red; 
        case .finalBoss: return .purple; 
        case .scout: return .orange; 
        case .mage: return .purple; 
        case .healer: return .green; 
        case .swarm: return .brown 
        } 
    }
    
    var hpColor: Color { 
        let ratio = Double(enemy.hp) / Double(max(enemy.maxHp, 1)); 
        if ratio > 0.6 { return Color(hex: "30D158") }; 
        if ratio > 0.3 { return Color(hex: "FFD60A") }; 
        return Color(hex: "FF453A") 
    }
}

struct PhaseCompleteView: View {
    @ObservedObject var game: GameModel
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "crown.fill").font(.system(size: 80)).foregroundColor(Color(hex: "FFD60A"))
            
            Text("¡FASE \(game.currentPhase) COMPLETADA!").font(.largeTitle).fontWeight(.bold).foregroundColor(Color(hex: "FFD60A"))
            
            VStack(spacing: 15) {
                Text("+50% HP Restaurado").font(.title3).foregroundColor(Color(hex: "30D158"))
                
                HStack {
                    Image(systemName: "heart.fill").foregroundColor(.red)
                    Text("\(game.player.hp)/\(game.player.maxHp)").foregroundColor(.white)
                }
            }
            .padding().background(Color(hex: "2C2C2E")).cornerRadius(15)
            
            if game.currentPhase < game.maxPhase {
                VStack(spacing: 10) {
                    Text("Próxima fase: \(game.currentPhase + 1)").font(.headline).foregroundColor(.gray)
                    Text("Los enemigos serán más fuertes (+15%)").font(.caption).foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Button(action: { 
                game.completePhase()
            }) { 
                Text("Continuar a la Tienda").font(.title2).fontWeight(.bold).foregroundColor(.white).frame(maxWidth: .infinity).padding().background(Color(hex: "BF5AF2")).cornerRadius(15) 
            }.padding(.horizontal)
            
            Spacer()
        }.frame(maxWidth: .infinity, maxHeight: .infinity).background(Color(hex: "1C1C1E"))
    }
}

struct BossRewardView: View {
    @ObservedObject var game: GameModel
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "gift.fill").font(.system(size: 80)).foregroundColor(Color(hex: "BF5AF2"))
            
            Text("¡BOSS DERROTADO!").font(.largeTitle).fontWeight(.bold).foregroundColor(.yellow)
            
            Text("Elige una reliquia:").font(.headline).foregroundColor(.white)
            
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(game.bossRewards) { relic in
                        Button(action: {
                            game.selectBossReward(relic)
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(relic.name).font(.headline).foregroundColor(.white)
                                    Text(relic.description).font(.caption).foregroundColor(.gray)
                                }
                                Spacer()
                                Image(systemName: relic.icon).font(.system(size: 30)).foregroundColor(Color(hex: relic.rarity.color))
                            }
                            .padding().background(Color(hex: "2C2C2E")).cornerRadius(15)
                        }
                    }
                }
                .padding()
            }
            
            Spacer()
        }.frame(maxWidth: .infinity, maxHeight: .infinity).background(Color(hex: "1C1C1E"))
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
