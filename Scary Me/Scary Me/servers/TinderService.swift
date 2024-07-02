import Foundation
import Combine

enum APIServiceError: Error {
    case invalidURL
    case noAuthToken
    case responseError(String)
    case noData
    case decodingError(Error)
}

class TinderService {
    static let shared = TinderService()
    
    private let baseURL = "http://itindr.mcenter.pro:8092/api/mobile/v1"
    
    func fetchUserFeed(completion: @escaping (Result<[User], APIServiceError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/user/feed") else {
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
                print("Fetch User Feed - Response error: \(error.localizedDescription)")
                completion(.failure(.responseError(error.localizedDescription)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Fetch User Feed - Invalid response")
                completion(.failure(.responseError("Invalid response")))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                print("Fetch User Feed - Response error: \(errorMessage)")
                completion(.failure(.responseError(errorMessage)))
                return
            }
            
            guard let data = data else {
                print("Fetch User Feed - No data")
                completion(.failure(.noData))
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Fetch User Feed - JSON Response: \(jsonString)")
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let users = try decoder.decode([User].self, from: data)
                print("Fetch User Feed - Fetched users: \(users)")
                completion(.success(users))
            } catch {
                print("Fetch User Feed - Decoding error: \(error)")
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }

    func postLike(userId: String, completion: @escaping (Result<Void, APIServiceError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/user/\(userId)/like") else {
            print("Invalid URL")
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "isMutual": true
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("Failed to serialize JSON body: \(error)")
            completion(.failure(.decodingError(error)))
            return
        }
        
        guard let authToken = UserDefaults.standard.string(forKey: "AccessToken") else {
            print("No auth token found")
            completion(.failure(.noAuthToken))
            return
        }
        
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Post Like - Response error: \(error.localizedDescription)")
                completion(.failure(.responseError(error.localizedDescription)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Post Like - Invalid response")
                completion(.failure(.responseError("Invalid response")))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                print("Post Like - Response error: \(errorMessage)")
                completion(.failure(.responseError(errorMessage)))
                return
            }
            
            completion(.success(()))
        }.resume()
    }
    
    func postDislike(userId: String, message: String, completion: @escaping (Result<Void, APIServiceError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/user/\(userId)/dislike") else {
            print("Invalid URL")
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "message": message
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("Failed to serialize JSON body: \(error)")
            completion(.failure(.decodingError(error)))
            return
        }
        
        guard let authToken = UserDefaults.standard.string(forKey: "AccessToken") else {
            print("No auth token found")
            completion(.failure(.noAuthToken))
            return
        }
        
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Post Dislike - Response error: \(error.localizedDescription)")
                completion(.failure(.responseError(error.localizedDescription)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Post Dislike - Invalid response")
                completion(.failure(.responseError("Invalid response")))
                return
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                completion(.success(()))
            case 409: 
                print("Post Dislike - Conflict")
                completion(.failure(.responseError("Conflict")))
            default:
                let errorMessage = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                print("Post Dislike - Response error: \(errorMessage)")
                completion(.failure(.responseError(errorMessage)))
            }
        }.resume()
    }
}
