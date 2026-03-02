import SwiftUI

struct StardewButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    let borderColor: Color
    let textColor: Color
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 220, height: 50)
                
                Rectangle()
                    .fill(borderColor)
                    .frame(width: 214, height: 44)
                    .offset(y: -2)
                
                Rectangle()
                    .fill(Color(red: 0.11, green: 0.11, blue: 0.12))
                    .frame(width: 210, height: 40)
                    .offset(y: -4)
                
                HStack(spacing: 10) {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .bold))
                    Text(title)
                        .font(.gothicButton)
                }
                .foregroundColor(textColor)
                .offset(y: -4)
            }
        }
    }
}
