import SwiftUI
import AVFoundation
import AudioToolbox

struct ImageButton: View {
    let normalImage: String
    let pressedImage: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            AudioServicesPlaySystemSound(1104)
            action()
        }) {
            VStack(spacing: 8) {
                Image(normalImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 50)
                    .shadow(
                        color: .black.opacity(0.6),
                        radius: 6,
                        x: 4,
                        y: 4
                    )
                
                Text(title)
                    .font(.gothicButton)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 2, y: 2)
            }
        }
        .buttonStyle(ImageButtonStyle())
    }
}

struct ImageButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
