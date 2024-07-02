import SwiftUI

struct FloatingTextField: View {
    @Binding var text: String
    var placeholder: String

    @State private var isEditing = false

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .leading) {
                Text(placeholder)
                    .font(.custom("BalooPaaji-Regular", size: 16))
                    .foregroundColor(.white.opacity(text.isEmpty ? (isEditing ? 0.5 : 1.0) : 0))
                    .padding(.horizontal, 16)
                    .padding(.top, isEditing || !text.isEmpty ? 0 : 16)
                 
                
                TextField("", text: $text, onEditingChanged: { editing in
                    withAnimation {
                        isEditing = editing
                    }
                }, onCommit: {
                   
                    if text.count > 50 {
                        text = String(text.prefix(50))
                    }
                })
                .foregroundColor(.white)
                .font(.custom("BalooPaaji-Regular", size: 16))
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 62/255, green: 28/255, blue: 51/255))
        )
    }
}

struct FloatingTextField_Previews: PreviewProvider {
    static var previews: some View {
        FloatingTextField(text: .constant(""), placeholder: "Enter your name")
            .background(Color.black)
            .previewLayout(.sizeThatFits)
    }
}
