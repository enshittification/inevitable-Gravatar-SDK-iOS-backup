import Foundation

private let baseURL = URL(string: "https://api.gravatar.com/v3/profiles/")!
private let avatarsBaseURLComponents = URLComponents(string: "https://api.gravatar.com/v3/me/avatars")!

private func selectAvatarBaseURL(with profileID: ProfileIdentifier) -> URL? {
    URL(string: "https://api.gravatar.com/v3/me/identities/\(profileID.id)/avatar")
}

/// A service to perform Profile related tasks.
///
/// By default, the ``Profile`` instance returned by ``fetch(with:)`` will contain only a subset of the abailable information.
///
/// To obtain the full profile information, you need to configure an API Key using ``Configuration``
public struct ProfileService: ProfileFetching, Sendable {
    private let client: HTTPClient

    /// Creates a new `ProfileService`.
    ///
    /// Optionally, you can pass a custom type conforming to ``HTTPClient`` to gain control over networking tasks.
    /// - Parameter client: A type which will perform basic networking operations.
    public init(client: HTTPClient? = nil) {
        self.client = client ?? URLSessionHTTPClient()
    }

    public func fetch(with profileID: ProfileIdentifier) async throws -> Profile {
        let url = baseURL.appending(pathComponent: profileID.id)
        let request = await URLRequest(url: url).authorized()
        return try await fetch(with: request)
    }

    package func fetchAvatars(with token: String, id: ProfileIdentifier) async throws -> [Avatar] {
        do {
            guard let url = avatarsBaseURLComponents.settingQueryItems([.init(name: "selected_email", value: id.id)]).url else {
                throw APIError.requestError(reason: .urlInitializationFailed)
            }
            let request = URLRequest(url: url).settingAuthorizationHeaderField(with: token)
            let (data, _) = try await client.fetchData(with: request)
            return try data.decode()
        } catch {
            throw error.apiError()
        }
    }

    package func selectAvatar(token: String, profileID: ProfileIdentifier, avatarID: String) async throws -> ProfileIdentity {
        guard let url = selectAvatarBaseURL(with: profileID) else {
            throw APIError.requestError(reason: .urlInitializationFailed)
        }

        do {
            var request = URLRequest(url: url).settingAuthorizationHeaderField(with: token)
            request.httpMethod = "POST"
            request.httpBody = try SelectAvatarBody(avatarId: avatarID).data
            let (data, _) = try await client.fetchData(with: request)
            return try data.decode(keyDecodingStrategy: .convertFromSnakeCase)
        } catch {
            throw error.apiError()
        }
    }
}

extension ProfileService {
    private func fetch(with request: URLRequest) async throws -> Profile {
        do {
            let (data, _) = try await client.fetchData(with: request)
            let profileResult: Profile = try data.decode()
            return profileResult
        } catch {
            throw error.apiError()
        }
    }
}

extension URLRequest {
    private enum HeaderField: String {
        case authorization = "Authorization"
    }

    fileprivate func authorized() async -> URLRequest {
        guard let key = await Configuration.shared.apiKey else { return self }
        let bearerKey = "Bearer \(key)"
        var copy = self
        copy.setValue(bearerKey, forHTTPHeaderField: HeaderField.authorization.rawValue)
        return copy
    }
}

package struct ProfileIdentity: Decodable, Sendable {
    package let emailHash: String
    package let rating: String
    package let imageId: String
    package let imageUrl: String
}

extension Avatar {
    public var id: String {
        imageId
    }

    public var url: String {
        imageUrl
    }

    public var isSelected: Bool {
        selected == true
    }
}

private struct SelectAvatarBody: Encodable, Sendable {
    private let avatarId: String

    init(avatarId: String) {
        self.avatarId = avatarId
    }

    var data: Data {
        get throws {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try encoder.encode(self)
        }
    }
}
