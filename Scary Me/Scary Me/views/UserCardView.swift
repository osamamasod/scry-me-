import SwiftUI
import SDWebImageSwiftUI

struct UserCardView: View {
    var user: User
    var matchCount: Int // this for match count

    let customColor = Color(UIColor(red: 177/255, green: 70/255, blue: 35/255, alpha: 1.0))

    var body: some View {
        VStack {
            if let avatarURL = user.avatar, let url = URL(string: avatarURL) {
                WebImage(url: url)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 360, height: 400)
                    .clipped()
                    .cornerRadius(10)
            } else {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 300, height: 400)
                    .clipped()
                    .cornerRadius(10)
            }

            VStack {
                Text(user.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 5)
                    .foregroundColor(.white)
                HStack {
                    Spacer()
                    Text("Matches: \(matchCount)")
                        .font(.title)
                        .foregroundColor(customColor)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
        }
        .background(Color(red: 62/255, green: 28/255, blue: 51/255))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}
