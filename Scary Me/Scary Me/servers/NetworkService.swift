import Foundation

struct RegistrationResponse: Codable {
    let success: Bool
    let message: String?
}

struct RegisterResponse: Codable {
    let accessToken: String
    let accessTokenExpiredAt: String
    let refreshToken: String
    let refreshTokenExpiredAt: String
}

class NetworkService {
    func registerUser(email: String, password: String, completion: @escaping (Result<RegisterResponse, Error>) -> Void) {
        guard let url = URL(string: "http://itindr.mcenter.pro:8092/api/mobile/v1/auth/register") else {
            print("Invalid URL")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "email": email,
            "password": password
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("JSON serialization error: \(error)")
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error - \(error)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("HTTP error - status code: \(httpResponse.statusCode)")
                let errorMessage = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }
            
            
           
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw response: \(rawResponse)")
            }
            
            do {
                let registrationResponse = try JSONDecoder().decode(RegisterResponse.self, from: data)
                
                // Save access token to UserDefaults
                UserDefaults.standard.set(registrationResponse.accessToken, forKey: "AccessToken")
                
                // Fetch topics after successful registration
                NetworkManager.shared.fetchTopics { result in
                 
                }
                
                completion(.success(registrationResponse))
            } catch {
                print("Decoding error - \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
}
