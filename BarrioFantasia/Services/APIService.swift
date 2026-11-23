import Foundation

public enum APIError: LocalizedError, Sendable {
    case invalidURL
    case networkError(String)
    case invalidResponse(Int)
    case unauthorized
    case decodingError

    public var errorDescription: String? {
        switch self {
        case .invalidURL: return "Dirección de servidor no válida."
        case .networkError(let msg): return "Error de red: \(msg)"
        case .invalidResponse(let code): return "Respuesta del servidor no esperada (código \(code))."
        case .unauthorized: return "Sesión caducada o credenciales incorrectas."
        case .decodingError: return "No se pudo interpretar la respuesta del servidor."
        }
    }
}

public struct UserProfile: Codable, Sendable {
    public let id: String
    public let email: String
    public let verified: Bool
}

public final class APIService: Sendable {
    public static let shared = APIService()

    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.httpCookieAcceptPolicy = .always
        config.httpShouldSetCookies = true
        self.session = URLSession(configuration: config)
    }

    public var serverURL: URL {
        let saved = UserDefaults.standard.string(forKey: "barrio_server_url") ?? "https://barriodefantasia.wacko87.es"
        return URL(string: saved) ?? URL(string: "https://barriodefantasia.wacko87.es")!
    }

    public func setServerURL(_ urlString: String) {
        UserDefaults.standard.set(urlString, forKey: "barrio_server_url")
    }

    public func checkHealth() async -> Bool {
        guard let url = URL(string: "/api/health", relativeTo: serverURL) else { return false }
        do {
            let (_, response) = try await session.data(from: url)
            guard let http = response as? HTTPURLResponse else { return false }
            return http.statusCode == 200
        } catch {
            return false
        }
    }

    public func login(email: String, pass: String) async throws -> UserProfile {
        guard let url = URL(string: "/api/login", relativeTo: serverURL) else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["email": email, "password": pass]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse(0) }

        if http.statusCode == 401 {
            throw APIError.unauthorized
        }
        guard (200...299).contains(http.statusCode) else {
            throw APIError.invalidResponse(http.statusCode)
        }

        struct LoginResponse: Codable {
            let user: UserProfile
        }

        let decoded = try JSONDecoder().decode(LoginResponse.self, from: data)
        return decoded.user
    }

    public func fetchCurrentMe() async throws -> UserProfile {
        guard let url = URL(string: "/api/me", relativeTo: serverURL) else { throw APIError.invalidURL }
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse(0) }
        guard http.statusCode == 200 else { throw APIError.unauthorized }

        struct MeResponse: Codable {
            let user: UserProfile
        }
        return try JSONDecoder().decode(MeResponse.self, from: data).user
    }

    public func toggleMatchSignup(matchId: String) async throws -> Bool {
        guard let url = URL(string: "/api/matches/\(matchId)/toggle-sign", relativeTo: serverURL) else { throw APIError.invalidURL }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        let (_, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse else { return false }
        return (200...299).contains(http.statusCode)
    }

    public func submitVote(voteId: String, data: [String: Any]) async throws -> Bool {
        guard let url = URL(string: "/api/docs/votes/\(voteId)", relativeTo: serverURL) else { throw APIError.invalidURL }
        var req = URLRequest(url: url)
        req.httpMethod = "PUT"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: data)
        let (_, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse else { return false }
        return (200...299).contains(http.statusCode)
    }
}
