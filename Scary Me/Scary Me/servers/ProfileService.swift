import Foundation

enum ProfileError: Error {
    case invalidURL
    case noAuthToken
    case responseError(String)
    case noData
    case decodingError(Error)
    case encodingError(Error)
}

struct Profile: Decodable {
    let userId: String
    let name: String
    let aboutMyself: String?
    var avatar: String?
    let topics: [Topic]
}

class ProfileService {
    static let shared = ProfileService()
    
    private let baseURL = "http://itindr.mcenter.pro:8092/api/mobile/v1"
    
    func fetchProfile(completion: @escaping (Result<Profile, ProfileError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/profile") else {
            print("Invalid URL")
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        guard let authToken = UserDefaults.standard.string(forKey: "AccessToken") else {
            print("No auth token found")
            completion(.failure(.noAuthToken))
            return
        }
        
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Fetch Profile - Response error: \(error.localizedDescription)")
                completion(.failure(.responseError(error.localizedDescription)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Fetch Profile - Invalid response")
                completion(.failure(.responseError("Invalid response")))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                print("Fetch Profile - Response error: \(errorMessage)")
                completion(.failure(.responseError(errorMessage)))
                return
            }
            
            guard let data = data else {
                print("Fetch Profile - No data")
                completion(.failure(.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                // Decode Profile object from JSON
                var profile = try decoder.decode(Profile.self, from: data)
                
                // Check if avatar is "null" and handle it
                if profile.avatar == "null" {
                    profile.avatar = nil
                }
                
                print("Fetch Profile - Fetched profile: \(profile)")
                completion(.success(profile))
            } catch {
                print("Fetch Profile - Decoding error: \(error)")
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    func updateProfile(name: String, about: String, avatarData: Data?, topics: [Topic], completion: @escaping (Result<Void, ProfileError>) -> Void) {
        print("Updating profile with name: \(name), about: \(about), topics: \(topics)")
        
        guard let url = URL(string: "\(baseURL)/profile") else {
            print("Update Profile - Invalid URL")
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        guard let authToken = UserDefaults.standard.string(forKey: "AccessToken") else {
            print("Update Profile - No auth token found")
            completion(.failure(.noAuthToken))
            return
        }
        
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        var requestBody: [String: Any] = [
            "name": name,
            "aboutMyself": about,
            "topics": topics.map { $0.id }
        ]
        
     
        if let avatarData = avatarData {
            requestBody["avatar"] = avatarData.base64EncodedString()
        }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
           
            if let bodyString = String(data: request.httpBody!, encoding: .utf8) {
                print("Update Profile - Request body: \(bodyString)")
            }
        } catch {
            print("Update Profile - Encoding error: \(error)")
            completion(.failure(.encodingError(error)))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Update Profile - Response error: \(error.localizedDescription)")
                completion(.failure(.responseError(error.localizedDescription)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Update Profile - Invalid response")
                completion(.failure(.responseError("Invalid response")))
                return
            }
            
            print("Update Profile - Response status code: \(httpResponse.statusCode)")
            
            if let responseData = data {
                let responseString = String(data: responseData, encoding: .utf8) ?? "Empty response data"
                print("Update Profile - Response data: \(responseString)")
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                print("Update Profile - Response error: \(errorMessage)")
                completion(.failure(.responseError(errorMessage)))
                return
            }
            
         
            print("Update Profile - Profile updated successfully")
            completion(.success(()))
        }.resume()
    }
}
