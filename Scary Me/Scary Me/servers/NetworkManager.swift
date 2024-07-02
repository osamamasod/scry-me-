import Foundation
import UIKit

enum NetworkError: Error {
    case invalidURL
    case noAuthToken
    case responseError(String)
    case noData
    case decodingError(Error)
}

class NetworkManager {
    static let shared = NetworkManager() // Singleton instance
    
    private let baseURL = "http://itindr.mcenter.pro:8092/api/mobile/v1"
    private var fetchedTopics: [Topic] = [] // Property to store fetched topics
    
    func fetchTopics(completion: @escaping (Result<[Topic], NetworkError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/topic") else {
            print("Invalid URL")
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let authToken = UserDefaults.standard.string(forKey: "AccessToken") else {
            print("No auth token found")
            completion(.failure(.noAuthToken))
            return
        }
        
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Response error: \(error.localizedDescription)")
                completion(.failure(.responseError(error.localizedDescription)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                completion(.failure(.responseError("Invalid response")))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                print("Response error: \(errorMessage)")
                completion(.failure(.responseError(errorMessage)))
                return
            }
            
            guard let data = data else {
                print("No data")
                completion(.failure(.noData))
                return
            }
            
            do {
                let topics = try JSONDecoder().decode([Topic].self, from: data)
                self.fetchedTopics = topics // Store fetched topics
                print("Fetched topics: \(topics)")
                completion(.success(topics))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    func uploadAvatar(image: UIImage, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/profile/avatar") else {
            print("Invalid URL")
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Add Authorization header
        guard let authToken = UserDefaults.standard.string(forKey: "AccessToken") else {
            print("No auth token found")
            completion(.failure(.noAuthToken))
            return
        }
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        // Create multipart form data body
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let imageData = image.jpegData(compressionQuality: 0.8)!
        var body = Data()
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"avatar\"; filename=\"avatar.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Response error: \(error.localizedDescription)")
                completion(.failure(.responseError(error.localizedDescription)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                completion(.failure(.responseError("Invalid response")))
                return
            }
            
            print("Response status code: \(httpResponse.statusCode)")
            if let responseData = data {
                let responseString = String(data: responseData, encoding: .utf8) ?? "Empty response data"
                print("Response data: \(responseString)")
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                print("Response error: \(errorMessage)")
                completion(.failure(.responseError(errorMessage)))
                return
            }
            
            completion(.success(()))
        }.resume()
    }
    
    func createProfile(name: String, aboutMyself: String, topics: [String], avatar: UIImage?, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/profile") else {
            print("Invalid URL")
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        
        // Set headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add Authorization header
        guard let authToken = UserDefaults.standard.string(forKey: "AccessToken") else {
            print("No auth token found")
            completion(.failure(.noAuthToken))
            return
        }
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        // Ensure topics contains valid IDs
        let topicIDs = topics.compactMap { title -> String? in
            // Find the corresponding topic ID based on title from fetchedTopics
            return fetchedTopics.first { $0.title == title }?.id
        }
        
        let profile: [String: Any] = [
            "name": name,
            "aboutMyself": aboutMyself,
            "topics": topicIDs
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: profile, options: [])
            print("Request JSON: \(String(data: jsonData, encoding: .utf8) ?? "Invalid JSON")")
            request.httpBody = jsonData
        } catch {
            print("Error serializing JSON: \(error)")
            completion(.failure(.decodingError(error)))
            return
        }
        
        func createProfileRequest() {
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Response error: \(error.localizedDescription)")
                    completion(.failure(.responseError(error.localizedDescription)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response")
                    completion(.failure(.responseError("Invalid response")))
                    return
                }
                
                print("Response status code: \(httpResponse.statusCode)")
                if let responseData = data {
                    let responseString = String(data: responseData, encoding: .utf8) ?? "Empty response data"
                    print("Response data: \(responseString)")
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    let errorMessage = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                    print("Response error: \(errorMessage)")
                    completion(.failure(.responseError(errorMessage)))
                    return
                }
                
                completion(.success(()))
            }.resume()
        }
        
        if let avatarImage = avatar {
            uploadAvatar(image: avatarImage) { result in
                switch result {
                case .success:
                    createProfileRequest()
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            createProfileRequest()
        }
    }
}
