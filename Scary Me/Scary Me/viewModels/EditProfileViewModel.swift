import Foundation
import SwiftUI

class EditProfileViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var aboutText: String = ""
    @Published var showImagePicker: Bool = false
    @Published var selectedImage: UIImage?
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var topics: [Topic] = []
    @Published var selectedTopics: Set<String> = []
    @Published var imageSource: UIImagePickerController.SourceType = .photoLibrary 
    
    private let profileService = ProfileService.shared
    
    func fetchProfile() {
        profileService.fetchProfile { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    self.userName = profile.name
                    self.aboutText = profile.aboutMyself ?? ""
                    self.topics = profile.topics
                    self.selectedTopics = Set(profile.topics.map { $0.title })
                    if let avatarURL = profile.avatar, let url = URL(string: avatarURL) {
                        self.downloadImage(from: url)
                    }
                case .failure(let error):
                    self.alertMessage = error.localizedDescription
                    self.showAlert = true
                }
            }
        }
    }
    
    func saveProfile() {
        guard let avatarData = self.selectedImage?.jpegData(compressionQuality: 0.5) else {
            
            return
        }
        
        profileService.updateProfile(name: self.userName, about: self.aboutText, avatarData: avatarData, topics: self.topics) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                   
                    self.fetchProfile()
                    
              
                    self.alertMessage = "Profile updated successfully"
                    self.showAlert = true
                    
                case .failure(let error):
                    self.alertMessage = error.localizedDescription
                    self.showAlert = true
                }
            }
        }
    }
    
    func toggleTopicSelection(_ topic: String) {
        if selectedTopics.contains(topic) {
            selectedTopics.remove(topic)
        } else {
            selectedTopics.insert(topic)
        }
    }
    
    func setImageSource(_ sourceType: UIImagePickerController.SourceType) {
        self.imageSource = sourceType
        self.showImagePicker = true
    }
    
    private func downloadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.selectedImage = image
                }
            } else {
                if let error = error {
                    print("Failed to download image:", error.localizedDescription)
                }
            }
        }.resume()
    }
}
