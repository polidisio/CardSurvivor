import SwiftUI

struct PixelButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let borderColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.gothicButton)
            .foregroundColor(.white)
            .frame(width: 220, height: 50)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(backgroundColor)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(borderColor, lineWidth: 3)
                    
                    VStack(spacing: 0) {
                        Rectangle().fill(borderColor).frame(height: 2)
                        Spacer()
                        Rectangle().fill(borderColor).frame(height: 2)
                    }
                    .padding(2)
                    
                    VStack(spacing: 0) {
                        Rectangle().fill(borderColor.opacity(0.5)).frame(height: 1)
                        Spacer()
                        Rectangle().fill(borderColor.opacity(0.5)).frame(height: 1)
                    }
                    .padding(4)
                }
            )
            .overlay(
                Group {
                    if configuration.isPressed {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.black.opacity(0.3))
                    }
                }
            )
            .shadow(color: .black.opacity(0.5), radius: 0, x: 3, y: 3)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

struct PixelButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    let backgroundColor: Color
    let borderColor: Color
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                Text(title)
                    .font(.gothicButton)
            }
            .foregroundColor(.white)
            .frame(width: 220, height: 50)
            .background(backgroundColor)
            .overlay(
                VStack(spacing: 0) {
                    Rectangle().fill(borderColor).frame(height: 3)
                    Spacer()
                    Rectangle().fill(borderColor).frame(height: 3)
                }
            )
            .overlay(
                VStack(spacing: 0) {
                    Rectangle().fill(borderColor.opacity(0.7)).frame(height: 1)
                    Spacer()
                    Rectangle().fill(borderColor.opacity(0.7)).frame(height: 1)
                }
                .padding(2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(borderColor, lineWidth: 4)
            )
            .shadow(color: .black, radius: 0, x: 4, y: 4)
        }
    }
}
