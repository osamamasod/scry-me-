
import Foundation
class SignInViewModel: ObservableObject {
    @Published var navigateToNextView = false
    @Published var errorMessage: String?

    private let authService = AuthService()

    func signIn(email: String, password: String) {
        authService.signInUser(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if !response.accessToken.isEmpty {
                        self?.navigateToNextView = true // Changed navigation destination
                    } else {
                        self?.errorMessage = "Sign in failed. Please try again."
                    }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func resetNavigation() {
        navigateToNextView = false
    }
}

