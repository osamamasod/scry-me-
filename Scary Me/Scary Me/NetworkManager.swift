//
//  NetworkManager.swift
//  Scary Me
//
//  Created by Osama Masoud on 6/12/24.
//

import Foundation
import Combine

class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    @Published var accessToken: String?
    @Published var refreshToken: String?

    private init() {}

    func signUp(email: String, password: String, repeatPassword: String) -> AnyPublisher<Bool, Error> {
        guard let url = URL(string: "http://itindr.mcenter.pro:8092/api/sign-up") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["email": email, "password": password, "repeatPassword": repeatPassword]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { result -> Bool in
                guard let httpResponse = result.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return true
            }
            .eraseToAnyPublisher()
    }

    func signIn(email: String, password: String) -> AnyPublisher<Bool, Error> {
        guard let url = URL(string: "http://itindr.mcenter.pro:8092/api/sign-in") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { result -> Bool in
                guard let httpResponse = result.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return true
            }
            .eraseToAnyPublisher()
    }

    func refreshToken() -> AnyPublisher<Bool, Error> {
        guard let url = URL(string: "http://itindr.mcenter.pro:8092/api/refresh-token") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["refreshToken": refreshToken ?? ""]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { result -> Bool in
                guard let httpResponse = result.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return true
            }
            .eraseToAnyPublisher()
    }
}
