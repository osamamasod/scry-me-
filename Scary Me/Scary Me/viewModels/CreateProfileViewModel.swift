import SwiftUI
import Combine

class CreateProfileViewModel: ObservableObject {
    @Published var showImagePicker = false
    @Published var selectedImage: UIImage? = UIImage(named: "defaultAvatar")
    @Published var imageSource: UIImagePickerController.SourceType = .photoLibrary
    @Published var userName = ""
    @Published var aboutText = ""
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var navigateToMainScreen = false
    @Published var topics: [Topic] = []
    @Published var selectedTopics: Set<String> = []
    
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
        fetchTopics()
    }
    
    func fetchTopics() {
        networkManager.fetchTopics { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedTopics):
                    self.topics = fetchedTopics
                case .failure(let error):
                    self.alertMessage = "Failed to fetch topics: \(error)"
                    self.showAlert = true
                }
            }
        }
    }
    
    func showImageSourceSelection() {
        showImagePicker = true
    }
    
    func saveProfile() {
        guard !userName.isEmpty else {
            alertMessage = "Username cannot be empty."
            showAlert = true
            return
        }
        
        let selectedTopicsArray = Array(selectedTopics)
        
        // here i save the selected topics loally to use it to count the mathches
        UserDefaults.standard.set(selectedTopicsArray, forKey: "selectedTopics")
        
        networkManager.createProfile(name: userName, aboutMyself: aboutText, topics: selectedTopicsArray, avatar: selectedImage) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.navigateToMainScreen = true
                case .failure(let error):
                    self.alertMessage = "Failed to create profile: \(error)"
                    self.showAlert = true
                }
            }
        }
    }
}
