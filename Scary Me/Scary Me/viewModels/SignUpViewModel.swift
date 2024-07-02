import Foundation

class SignUpViewModel: ObservableObject {
    @Published var navigateToCreateProfile = false
    @Published var errorMessage: String?

    private let networkService = NetworkService()

    func register(email: String, password: String) {
        networkService.registerUser(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self?.navigateToCreateProfile = true
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
