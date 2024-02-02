import UIKit

public enum GravatarServiceError: Error {
    case invalidAccountInfo
    case invalidURL
    case unexpected(Error)
}

extension GravatarServiceError: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .invalidAccountInfo:
            return "Invalid account info"
        case .invalidURL:
            return "Invalid URL"
        case .unexpected(let error):
            return "An unexpected error has occoured: \(error)"
        }
    }
}

/// This Service exposes all of the valid operations we can execute, to interact with the Gravatar Service.
///
open class GravatarService {

    public init() {}

    /// This method fetches the Gravatar profile for the specified email address.
    ///
    /// - Parameters:
    ///     - email: The email address of the gravatar profile to fetch.
    ///     - completion: A completion block.
    ///
    open func fetchProfile(email: String, onCompletion: @escaping ((_ result: GravatarProfileFetchResult) -> Void)) {
        guard !email.isEmpty else {
            onCompletion(.failure(GravatarServiceError.invalidAccountInfo))
            return
        }
        
        let remote = gravatarServiceRemote()
        remote.fetchProfile(email.normalized(), success: { remoteProfile in
            var profile = GravatarProfile()
            profile.profileID = remoteProfile.profileID
            profile.hash = remoteProfile.hash
            profile.requestHash = remoteProfile.requestHash
            profile.profileUrl = remoteProfile.profileUrl
            profile.preferredUsername = remoteProfile.preferredUsername
            profile.thumbnailUrl = remoteProfile.thumbnailUrl
            profile.name = remoteProfile.name
            profile.displayName = remoteProfile.displayName
            onCompletion(.success(profile))

        }, failure: { error in
            onCompletion(.failure(GravatarServiceError.invalidAccountInfo))
        })
    }


    /// This method hits the Gravatar Endpoint, and uploads a new image, to be used as profile.
    ///
    /// - Parameters:
    ///     - image: The new Gravatar Image, to be uploaded
    ///     - accountEmail: Email address associated with the image
    ///     - accountToken: OAuth token
    ///     - completion: An optional closure to be executed on completion.
    ///
    open func uploadImage(_ image: UIImage, accountEmail: String, accountToken: String, completion: ((_ error: NSError?) -> ())? = nil) {
        guard !accountEmail.isEmpty,
              !accountToken.isEmpty else {
            completion?(GravatarServiceError.invalidAccountInfo as NSError)
            return
        }

        let remote = gravatarServiceRemote()
        remote.uploadImage(
            image,
            accountEmail: accountEmail.normalized(),
            accountToken: accountToken,
            completion: completion
        )
    }

    /// Overridden by tests for mocking.
    ///
    open func gravatarServiceRemote() -> GravatarServiceRemote {
        return GravatarServiceRemote()
    }
}

extension String {
    func normalized() -> String {
        self.trimmingCharacters(in: .whitespaces).lowercased()
    }
}
