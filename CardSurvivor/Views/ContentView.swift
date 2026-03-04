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

struct MoonlightText: View {
    let text: String
    let baseColor: Color
    let glowColor: Color
    
    @State private var pulseAmount: CGFloat = 0.5
    
    var body: some View {
        ZStack {
            Text(text)
                .font(.gothicTitle)
                .foregroundColor(glowColor.opacity(pulseAmount + 0.4))
                .blur(radius: 25)
                .scaleEffect(1.15)
            
            Text(text)
                .font(.gothicTitle)
                .foregroundColor(glowColor.opacity(pulseAmount + 0.2))
                .blur(radius: 12)
                .scaleEffect(1.08)
            
            Text(text)
                .font(.gothicTitle)
                .foregroundColor(baseColor)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulseAmount = 0.8
            }
        }
    }
}

struct MainMenuView: View {
    @ObservedObject var game: GameModel
    
    var body: some View {
        ZStack {
            Image("menu")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay(Color.black.opacity(0.6))
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                VStack(spacing: 10) {
                    MoonlightText(text: "CARD", baseColor: Color(hex: "DC143C"), glowColor: Color(hex: "FF6B6B"))
                    MoonlightText(text: "SURVIVOR", baseColor: .white, glowColor: Color(hex: "E8F4FF"))
                }
                Spacer()
                VStack(spacing: 20) {
                    ImageButton(normalImage: "Next_Unpressed", pressedImage: "Next_Pressed", title: "JUGAR", action: { game.state = .classSelection })
                    ImageButton(normalImage: "Stats_Unpressed", pressedImage: "Stats_Pressed", title: "PERFIL", action: { game.state = .profile })
                    ImageButton(normalImage: "Info_Unpressed", pressedImage: "Info_Pressed", title: "AJUSTES", action: { game.state = .settings })
                }
                Spacer()
                HStack { Image(systemName: "diamond.fill").foregroundColor(Color(hex: "00D4FF")); Text("\(game.progression.gems)").foregroundColor(Color(hex: "00D4FF")).font(.headline) }
                .padding(.horizontal, 16).padding(.vertical, 8).background(Color(hex: "00D4FF").opacity(0.2)).cornerRadius(20)
                Spacer()
            }
        }
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

struct TarotClassCard: View {
    let playerClass: PlayerClass
    let isSelected: Bool
    
    @State private var glowOpacity: Double = 0.5
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "1C1C1E"), Color(hex: "2C2C2E")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            HStack(spacing: 0) {
                Image(classImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 110)
                    .clipped()
                    .cornerRadius(8)
                    .padding(.leading, 8)
                    .padding(.vertical, 8)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(playerClass.name)
                        .font(.gothicTitle2)
                        .foregroundColor(.white)
                        .shadow(color: Color(hex: "DC143C").opacity(isSelected ? glowOpacity : 0), radius: 10)
                    
                    Text(playerClass.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles").foregroundColor(Color(hex: "FFD60A"))
                        Text(playerClass.passiveAbility)
                            .font(.caption2)
                            .foregroundColor(Color(hex: "FFD60A"))
                    }
                }
                .padding(.vertical, 15)
                .padding(.horizontal, 12)
                
                Spacer()
                
                VStack(spacing: 8) {
                    StatBadge(icon: "heart.fill", value: "\(playerClass.baseHP)", color: .red)
                    StatBadge(icon: "bolt.fill", value: "\(playerClass.baseEnergy)", color: Color(hex: "FFD60A"))
                    StatBadge(icon: "flame.fill", value: "\(playerClass.baseDamage)", color: .orange)
                }
                .padding(.trailing, 15)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color(hex: "DC143C") : Color(hex: "3C3C3E"),
                        lineWidth: isSelected ? 3 : 1
                    )
                    .shadow(color: Color(hex: "DC143C").opacity(isSelected ? glowOpacity : 0), radius: isSelected ? 15 : 0)
            )
            .cornerRadius(12)
        }
        .frame(width: 320, height: 150)
        .scaleEffect(isSelected ? 1.0 : 0.9)
        .opacity(isSelected ? 1.0 : 0.7)
        .animation(.easeInOut(duration: 0.3), value: isSelected)
        .onAppear {
            if isSelected {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    glowOpacity = 0.8
                }
            }
        }
    }
    
    var classImageName: String {
        switch playerClass {
        case .warrior: return "Guerrero"
        case .mage: return "Mago"
        case .rogue: return "Picaro"
        case .paladin: return "Paladin"
        }
    }
}

struct StatBadge: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.caption2).foregroundColor(color)
            Text(value).font(.caption).fontWeight(.bold).foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.2))
        .cornerRadius(8)
    }
}

struct DeckPreviewView: View {
    let playerClass: PlayerClass
    let onSelect: () -> Void
    
    private var deck: [Card] {
        Player.createStartingDeck(for: playerClass)
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Text("MAZO INICIAL - \(playerClass.name.uppercased())")
                .font(.gothicBody)
                .foregroundColor(.white)
                .shadow(color: .black, radius: 3)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(deck, id: \.id) { card in
                        SmallCardPreview(card: card)
                    }
                }
                .padding(.horizontal, 20)
            }
            
            Button(action: onSelect) {
                Text("JUGAR")
                    .font(.gothicButton)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 180, height: 45)
                    .background(Color(hex: "DC143C"))
                    .cornerRadius(20)
                    .shadow(color: Color(hex: "DC143C").opacity(0.5), radius: 8)
            }
        }
        .padding(.vertical, 20)
    }
}

struct SmallCardPreview: View {
    let card: Card
    
    var body: some View {
        ZStack {
            if let imageName = card.imageName {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 70, height: 100)
                    .clipped()
            } else {
                Image("CardFrame")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 70, height: 100)
            }
            
            VStack(spacing: 1) {
                HStack {
                    Image(systemName: iconForCardType(card.type))
                        .font(.system(size: 10))
                        .foregroundColor(cardColor)
                    Spacer()
                    Text("\(card.cost)")
                        .font(.system(size: 10))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 16, height: 16)
                        .background(cardColor)
                        .clipShape(Circle())
                }
                .padding(.horizontal, 6)
                .padding(.top, 6)
                
                Spacer()
                
                Text(card.name)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.white)
                    .textCase(.uppercase)
                    .lineLimit(1)
                    .shadow(color: .black, radius: 2)
                
                Text("\(card.value)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(cardColor)
                    .shadow(color: .black, radius: 2)
                
                Text(card.description)
                    .font(.system(size: 5))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 4)
                    .shadow(color: .black, radius: 2)
            }
            .frame(width: 64, height: 94)
        }
        .frame(width: 70, height: 100)
    }
    
    var cardColor: Color {
        switch card.type {
        case .attack: return Color(hex: "FF453A")
        case .defense: return Color(hex: "0A84FF")
        case .power: return Color(hex: "BF5AF2")
        case .draw: return Color(hex: "30D158")
        case .special: return Color(hex: "FFD60A")
        }
    }
    
    func iconForCardType(_ type: Card.CardType) -> String {
        switch type {
        case .attack: return "bolt.fill"
        case .defense: return "shield.fill"
        case .power: return "star.fill"
        case .draw: return "arrow.down.circle.fill"
        case .special: return "sparkles"
        }
    }
}

struct ClassSelectionView: View {
    @ObservedObject var game: GameModel
    @State private var selectedIndex: Int = 0
    
    private let classes = PlayerClass.allCases
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Imagen de fondo
                Image("bg_class_selection")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .overlay(Color.black.opacity(0.6))
                
                // Botón volver
                VStack {
                    HStack {
                        Button(action: { game.state = .mainMenu }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        .padding(.leading, 20)
                        .padding(.top, 20)
                        Spacer()
                    }
                    Spacer()
                }
                
                VStack(spacing: 20) {
                    // Título grande centrado
                    Text("SELECCIONA TU DESTINO")
                        .font(.gothicTitle2)
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 5)
                        .padding(.top, 60)
                    
                    Spacer()
                    
                    TabView(selection: $selectedIndex) {
                        // Slides de cada clase: Card + Mazo (2 por clase)
                        ForEach(0..<classes.count, id: \.self) { classIndex in
                            let playerClass = classes[classIndex]
                            
                            // Slide 1: Card de la clase
                            VStack(spacing: 15) {
                                TarotClassCard(playerClass: playerClass, isSelected: true)
                                
                                Button(action: {
                                    withAnimation {
                                        // Ir al slide del mazo
                                        selectedIndex = classIndex * 2 + 1
                                    }
                                }) {
                                    Text("VER MAZO")
                                        .font(.gothicButton)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(width: 180, height: 45)
                                        .background(Color(hex: "BF5AF2"))
                                        .cornerRadius(20)
                                        .shadow(color: Color(hex: "BF5AF2").opacity(0.5), radius: 8)
                                }
                            }
                            .tag(classIndex * 2)
                            
                            // Slide 2: Mazo de cartas
                            VStack(spacing: 10) {
                                DeckPreviewView(playerClass: playerClass) {
                                    game.selectClass(playerClass)
                                    game.startNewGame()
                                }
                            }
                            .tag(classIndex * 2 + 1)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    // 8 puntos indicadores (2 por clase)
                    HStack(spacing: 8) {
                        ForEach(0..<(classes.count * 2), id: \.self) { index in
                            Circle()
                                .fill(index == selectedIndex ? Color(hex: "DC143C") : Color.gray.opacity(0.5))
                                .frame(width: 8, height: 8)
                                .animation(.easeInOut(duration: 0.2), value: selectedIndex)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
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
    
    private var waveBackground: String {
        let waveNum = game.wave
        if game.state == .waveComplete || game.state == .phaseComplete {
            return "wave_complete"
        } else if game.state == .bossReward {
            return "wave_victory"
        } else {
            return "wave_\(String(format: "%02d", waveNum))"
        }
    }
    
    var body: some View {
        ZStack {
            Image(waveBackground)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
                .overlay(Color.black.opacity(0.4))
            
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
        ZStack {
            // Imagen de fondo de la carta si existe
            if let imageName = card.imageName {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 110, height: 150)
                    .clipped()
                    .cornerRadius(12)
                
                // Overlay para hacer legible el texto
                VStack(spacing: 2) {
                    HStack {
                        Image(systemName: iconForCardType(card.type))
                            .font(.caption)
                            .foregroundColor(cardColor)
                        Spacer()
                        Text("\(card.cost)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                            .background(cardColor)
                            .clipShape(Circle())
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 8)
                    
                    Spacer()
                    
                    Text(card.name)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .textCase(.uppercase)
                        .lineLimit(1)
                        .shadow(color: .black, radius: 2)
                    
                    if card.value > 0 {
                        Text("\(card.value)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(cardColor)
                            .shadow(color: .black, radius: 2)
                    } else {
                        Spacer().frame(height: 25)
                    }
                    
                    Text(card.description)
                        .font(.system(size: 8))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 6)
                        .shadow(color: .black, radius: 2)
                    
                    if showPrice {
                        Text("\(price)")
                            .font(.caption2)
                            .foregroundColor(Color(hex: "FFD60A"))
                            .shadow(color: .black, radius: 2)
                    }
                }
                .frame(width: 110, height: 150)
            } else {
                // Diseño original si no hay imagen
                VStack(spacing: 4) {
                    HStack { Image(systemName: iconForCardType(card.type)).foregroundColor(cardColor).font(.caption); Spacer(); Text("\(card.cost)").font(.caption).fontWeight(.bold).foregroundColor(.white).padding(.horizontal, 6).padding(.vertical, 2).background(cardColor).cornerRadius(4) }
                    Text(card.name).font(.caption).fontWeight(.bold).foregroundColor(.white).lineLimit(1)
                    if card.value > 0 { Text("\(card.value)").font(.title).fontWeight(.bold).foregroundColor(cardColor) } else { Spacer().frame(height: 30) }
                    Text(card.description).font(.caption2).foregroundColor(.gray).lineLimit(2).multilineTextAlignment(.center)
                    if showPrice { Text("\(price)").font(.caption2).foregroundColor(Color(hex: "FFD60A")) }
                }
                .padding(10).frame(width: 110, height: 150).background(isSelected ? cardColor.opacity(0.3) : cardBackground).cornerRadius(12)
            }
        }
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
