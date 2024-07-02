




import SwiftUI

struct SwipeCardStack<Content: View>: View {
    var users: [User]
    var swipedCards: Set<Int> // Track swiped cards
    var content: (User, Int) -> Content
    @Binding var currentIndex: Int
    var viewModel: TinderViewModel

    @GestureState private var translation: CGFloat = 0
    @State private var hasDisliked = false

    var swipeRightAction: () -> Void
    var swipeLeftAction: () -> Void

    var body: some View {
        ZStack {
            ForEach(users.indices, id: \.self) { index in
                if !swipedCards.contains(index) {
                    let matchCount = viewModel.matchingTopicsCount(currentUser: users[currentIndex], otherUser: users[index])

                    content(users[index], matchCount)
                        .offset(x: index == currentIndex ? translation : (index < currentIndex ? -500 : 500), y: 0)
                        .animation(.spring())
                        .gesture(
                            DragGesture()
                                .updating($translation) { value, state, _ in
                                    state = value.translation.width
                                }
                                .onEnded { value in
                                    let swipeThreshold: CGFloat = 100
                                    if value.translation.width > swipeThreshold {
                                        if !hasDisliked {
                                            swipeRightAction()
                                            hasDisliked = true
                                        }
                                    } else if value.translation.width < -swipeThreshold {
                                        if !hasDisliked {
                                            swipeLeftAction()
                                            hasDisliked = true
                                        }
                                    }
                                }
                        )
                }
            }
        }
    }
}
