
//
//  CustomizeTextField.swift
//  Scary Me
//
//  Created by Osama Masoud on 6/11/24.
//

import SwiftUI

struct CustomizeTextField: View {
    @Binding var text: String
    var placeholder: String

    @State private var isEditing = false

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .leading) {
                TextField(placeholder, text: $text)
                    .font(.custom("BalooPaaji-Regular", size: 16))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .opacity(isEditing || !text.isEmpty ? 1.0 : 0.5)
                    .onTapGesture {
                        isEditing = true
                    }

                if text.isEmpty {
                    Text(placeholder)
                        .font(.custom("BalooPaaji-Regular", size: 16))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.horizontal, 16)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 62/255, green: 28/255, blue: 51/255))
        )
    }
}

struct CustomizeTextField_Previews: PreviewProvider {
    static var previews: some View {
        CustomizeTextField(text: .constant(""), placeholder: "Enter your name")
            .background(Color.black)
            .previewLayout(.sizeThatFits)
    }
}
