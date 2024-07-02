import SwiftUI

struct TinderView: View {
    @StateObject private var viewModel = TinderViewModel()
    @State private var currentIndex: Int = 0
    @State private var swipedCards = Set<Int>() // Track swiped cards
    @State private var selectedUser: User? = nil // Track selected user for navigation

    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                VStack {
                    ZStack(alignment: .topLeading) {
                        CustomShape()
                            .fill(Color(red: 62/255, green: 28/255, blue: 51/255))
                            .frame(height: UIScreen.main.bounds.height / 2)
                            .cornerRadius(40, corners: [.bottomLeft, .bottomRight])
                            .ignoresSafeArea(edges: .top)

                        Text("Trick or Treat?")
                            .foregroundColor(.white)
                            .padding()
                            .font(.largeTitle)
                            .offset(x: -10, y: -30)
                    }

                    Spacer()
                }

                VStack {
                    SwipeCardStack(users: viewModel.users,
                                   swipedCards: swipedCards,
                                   content: { user, matchCount in
                                       Button(action: {
                                           selectedUser = user
                                       }) {
                                           UserCardView(user: user, matchCount: matchCount)
                                       }
                                   },
                                   currentIndex: $currentIndex,
                                   viewModel: viewModel,
                                   swipeRightAction: {
                                       handleSwipeRight()
                                       likeCurrent()
                                   },
                                   swipeLeftAction: {
                                       handleSwipeLeft()
                                       dislikeCurrent()
                                   })
                        .padding(.horizontal)

                    HStack(spacing: 160) {
                        Button(action: {
                            handleSwipeLeft()
                            dislikeCurrent()
                        }) {
                            Image("dislike")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                                .foregroundColor(.blue)
                        }
                        .padding(.bottom, 20)

                        Button(action: {
                            handleSwipeRight()
                            likeCurrent()
                        }) {
                            Image("Like")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                        }
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal)
                    .opacity(currentIndex < viewModel.users.count && currentIndex >= 0 ? 1 : 0)
                }
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .background(
                Group {
                    if let user = selectedUser {
                        NavigationLink(
                            destination: UserProfileView(user: user)
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
    }

    private func handleSwipeRight() {
        guard currentIndex < viewModel.users.count else { return }
        let user = viewModel.users[currentIndex]
        viewModel.likeUser(userId: user.id)
        swipedCards.insert(currentIndex)
        updateCurrentIndex()
    }

    private func handleSwipeLeft() {
        guard currentIndex < viewModel.users.count else { return }
        let user = viewModel.users[currentIndex]
        viewModel.dislikeUser(userId: user.id, message: "Disliked")
        swipedCards.insert(currentIndex)
        updateCurrentIndex()
    }

    private func likeCurrent() {
        guard currentIndex < viewModel.users.count else { return }
        let userId = viewModel.users[currentIndex].id
        viewModel.likeUser(userId: userId)
    }

    private func dislikeCurrent() {
        guard currentIndex < viewModel.users.count else { return }
        let userId = viewModel.users[currentIndex].id
        viewModel.dislikeUser(userId: userId, message: "Not interested")
    }

    private func updateCurrentIndex() {
        while currentIndex < viewModel.users.count - 1 && swipedCards.contains(currentIndex) {
            currentIndex += 1
        }
    }
}


struct CustomShape: Shape {
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


extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}


struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}


struct TinderView_Previews: PreviewProvider {
    static var previews: some View {
        TinderView()
    }
}
