import SwiftUI

struct UserProfileView: View {
    var user: User
    @StateObject private var imageLoader = ImageLoader()
    @State private var currentIndex: Int = 0
    @State private var swipedCards = Set<Int>()
    @StateObject private var viewModel = TinderViewModel()
    @State private var shouldNavigateToTinder = false
    @State private var likeButtonTapped = false
    @State private var dislikeButtonTapped = false

    var body: some View {
        ZStack(alignment: .top) {
            Color.black
                .ignoresSafeArea()

            CustomeShape()
                .fill(Color(red: 62/255, green: 28/255, blue: 51/255))
                .frame(height: UIScreen.main.bounds.height / 2)
                .frame(maxWidth: .infinity)
                .cornerRadius(40, corners: [.bottomLeft, .bottomRight])
                .ignoresSafeArea(edges: .top)

            VStack {
                if let avatarURL = user.avatar, let url = URL(string: avatarURL) {
                    Image(uiImage: imageLoader.image ?? UIImage(systemName: "person.circle.fill")!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .padding(.top, 20)
                        .onAppear {
                            imageLoader.loadImage(from: url)
                        }
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .padding(.top, 20)
                }

                Text(user.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 10)
            }
            .padding(.top, 50)

            GeometryReader { geometry in
                VStack {
                    Spacer()
                        .frame(height: geometry.size.height / 2)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(user.topics, id: \.id) { topic in
                                Text(topic.title)
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.orange)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(Color.orange, lineWidth: 1)
                                            )
                                    )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 50)

                    if let about = user.aboutMyself {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(about)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                        }
                        .padding(.top, 20)
                        .padding(.horizontal)
                    }

                    Spacer()
                }
                .padding(.bottom, 50)
            }

            VStack {
                Spacer()

                HStack(spacing: 120) { // Adjusted spacing here
                    Button(action: {
                        likeCurrent()
                        likeButtonTapped = true
                    }) {
                        Image("Like")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .foregroundColor(.green)
                    }
                    .padding(.bottom, 20)

                    Button(action: {
                        dislikeCurrent()
                        dislikeButtonTapped = true
                    }) {
                        Image("dislike")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .foregroundColor(.blue)
                    }
                    .padding(.bottom, 20)
                }
                .padding(.horizontal)
                .opacity(currentIndex < user.topics.count && currentIndex >= 0 ? 1 : 0)
            }
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .background(
            Group {
                if likeButtonTapped || dislikeButtonTapped {
                    NavigationLink(
                        destination: TinderView()
                            .navigationBarBackButtonHidden(true),
                        isActive: .constant(true),
                        label: {
                            EmptyView()
                        }
                    )
                    .isDetailLink(false)
                    .hidden()
                }
            }
        )
    }

    private func likeCurrent() {
        guard currentIndex < user.topics.count else { return }
        let userId = user.id
        viewModel.likeUser(userId: userId)
        swipedCards.insert(currentIndex)
        updateCurrentIndex()
    }

    private func dislikeCurrent() {
        guard currentIndex < user.topics.count else { return }
        let userId = user.id
        viewModel.dislikeUser(userId: user.id, message: "Not interested")
        swipedCards.insert(currentIndex)
        updateCurrentIndex()
    }

    private func updateCurrentIndex() {
        while currentIndex < user.topics.count - 1 && swipedCards.contains(currentIndex) {
            currentIndex += 1
        }
    }
}

struct CustomeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addArc(center: CGPoint(x: rect.width - 40, y: rect.height), radius: 40, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        path.addLine(to: CGPoint(x: 40, y: rect.height))
        path.addArc(center: CGPoint(x: 40, y: rect.height), radius: 40, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}
