
import Foundation

struct User: Codable, Identifiable {
    var id: String { userId }
    let userId: String
    let name: String
    let aboutMyself: String?
    let avatar: String?
    let topics: [Topic]
}

struct Topic: Codable, Identifiable {
    let id: String
    let title: String
}

    
    enum CodingKeys: String, CodingKey {
        case id = "userId"
        case name
        case aboutMyself
        case avatar
        case topics
    }

