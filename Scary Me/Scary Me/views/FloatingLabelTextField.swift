import SwiftUI

struct FloatingLabelTextField: View {
    @Binding var text: String
    let placeholder: String
    let isSecure: Bool

    @State private var isEditing = false

    var body: some View {
        ZStack(alignment: .leading) {
            Text(placeholder)
                .foregroundColor(.gray)
                
                .padding(.horizontal, 5)
                .offset(y: text.isEmpty && !isEditing ? 0 : -25)
                .scaleEffect(text.isEmpty && !isEditing ? 1 : 0.8, anchor: .leading)
                .animation(.easeInOut(duration: 0.2), value: text.isEmpty && !isEditing)

            if isSecure {
                SecureField("", text: $text)
                    .padding(.top, text.isEmpty && !isEditing ? 0 : 20)
                    .onTapGesture {
                        withAnimation {
                            isEditing = true
                        }
                    }
            } else {
                TextField("", text: $text)
                    .padding(.top, text.isEmpty && !isEditing ? 0 : 20)
                    .onTapGesture {
                        withAnimation {
                            isEditing = true
                        }
                    }
            }
        }
        .padding(.all, 16)
        .background(Color.white)
        .cornerRadius(8)
        .padding(.horizontal, 16)
        .onChange(of: text) { _ in
            if text.isEmpty {
                withAnimation {
                    isEditing = false
                }
            }
        }
    }
}
