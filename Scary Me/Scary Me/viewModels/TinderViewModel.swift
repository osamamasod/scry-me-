import Foundation
import Combine

class TinderViewModel: ObservableObject {
    @Published var users: [User] = []
    private var cancellables = Set<AnyCancellable>()
    private var selectedTopics: [String] = [] //  property to store the  selected topics

    init() {
        fetchUsers()
        loadSelectedTopics()
    }

    func fetchUsers() {
        TinderService.shared.fetchUserFeed { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    self.users = users
                case .failure(let error):
                    print("Error fetching users: \(error)")
                    // Handle error, show alert, etc.
                }
            }
        }
    }

    func likeUser(userId: String) {
        TinderService.shared.postLike(userId: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Successfully liked user with id \(userId)")
                    // Optionally, update UI or perform any post-like action
                case .failure(let error):
                    print("Error liking user: \(error)")
                    // Handle error, show alert, etc.
                }
            }
        }
    }

    func dislikeUser(userId: String, message: String) {
        TinderService.shared.postDislike(userId: userId, message: message) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Successfully disliked user with id \(userId)")
                   
                case .failure(let error):
                    print("Error disliking user: \(error)")
                    
                }
            }
        }
    }

    func matchingTopicsCount(currentUser: User, otherUser: User) -> Int {
        let currentUserTopics = Set(selectedTopics) // Use selected topics from UserDefaults
        let otherUserTopics = Set(otherUser.topics.map { $0.title })
        return currentUserTopics.intersection(otherUserTopics).count
    }

    func selectUser(_ user: User) {
      
        print("Selected user: \(user.name)")
       
    }

    private func loadSelectedTopics() {
        if let storedTopics = UserDefaults.standard.array(forKey: "selectedTopics") as? [String] {
            self.selectedTopics = storedTopics
        }
    }
}
