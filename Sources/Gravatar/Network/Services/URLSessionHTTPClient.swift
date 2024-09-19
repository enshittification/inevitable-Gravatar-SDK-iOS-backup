import Foundation

/// Common errors for all HTTP operations.
enum HTTPClientError: Error {
    case invalidHTTPStatusCodeError(HTTPURLResponse)
    case invalidURLResponseError(URLResponse)
    case URLSessionError(Error)
}

struct URLSessionHTTPClient: HTTPClient {
    private let urlSession: URLSessionProtocol

    init(urlSession: URLSessionProtocol = URLSession(configuration: .default)) {
        self.urlSession = urlSession
    }

    func fetchData(with request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let result: (data: Data, response: URLResponse)
        do {
            result = try await urlSession.data(for: request)
        } catch {
            throw HTTPClientError.URLSessionError(error)
        }
        let httpResponse = try validatedHTTPResponse(result.response)
        return (result.data, httpResponse)
    }

    func uploadData(with request: URLRequest, data: Data) async throws -> (Data, HTTPURLResponse) {
        let result: (data: Data, response: URLResponse)
        do {
            result = try await urlSession.upload(for: request, from: data)
        } catch {
            throw HTTPClientError.URLSessionError(error)
        }
        return try (result.data, validatedHTTPResponse(result.response))
    }
}

extension URLRequest {
    func settingAuthorizationHeaderField(with token: String) -> URLRequest {
        self.settingHeader(value: "Bearer \(token)", forHTTPHeaderField: "Authorization")
    }

    /// Returns a `URLRequest` with the `Accept-Language` header set using the provided `value`
    ///
    /// To specify the user's preferred languages, use `settingDefaultAcceptLanguage()`
    ///
    /// - Parameter value: The `Accept-Language` value.
    /// - Returns: `URLRequest` with the `Accept-Language` header set
    func settingAcceptLanguage(_ value: String) -> URLRequest {
        self.settingHeader(value: value, forHTTPHeaderField: "Accept-Language")
    }

    /// Returns a `URLRequest` with a default `Accept-Language` header, generated by querying `Locale` for the user's
    /// `preferredLanguages`.
    ///
    /// See the [Accept-Language HTTP header documentation](https://tools.ietf.org/html/rfc7231#section-5.3.5).
    ///
    /// - Parameter languagePreferenceProvider: an instance that conforms to `LanguagePreferenceProvider`
    /// - Returns: `URLRequest` with the `Accept-Language` header set to the user's preferred languages
    func settingDefaultAcceptLanguage(languagePreferenceProvider: LanguagePreferenceProvider = SystemLanguagePreferenceProvider()) -> URLRequest {
        settingAcceptLanguage(
            languagePreferenceProvider.preferredLanguages.prefix(
                languagePreferenceProvider.maxPreferredLanguages
            ).qualityEncoded()
        )
    }

    func settingHeader(value: String, forHTTPHeaderField httpHeaderField: String) -> URLRequest {
        var copy = self
        copy.setValue(value, forHTTPHeaderField: httpHeaderField)
        return copy
    }
}

extension Collection<String> {
    /// Returns a string that can be used as the value of an `Accept-Language` header.
    ///
    /// ## Example
    ///
    /// `[da, en-gb, en]` --> `"da, en-gb;q=0.9, en;q=0.8"`
    ///
    /// Which means:
    /// "I prefer Danish, but will accept British English and other types of English"
    ///
    /// See the [Accept-Language HTTP header documentation](https://tools.ietf.org/html/rfc7231#section-5.3.5).
    ///
    /// - Returns: a `String` representing the preferred languages, to be used as the `value` of the `Accept-Language` header
    func qualityEncoded() -> String {
        self.enumerated().map { index, encoding in
            let qValue = 1.0 - (Double(index) * 0.1) // Decrease the q-value for each encoding
            return index == 0 ? encoding : "\(encoding);q=\(qValue)"
        }.joined(separator: ", ")
    }
}

private func validatedHTTPResponse(_ response: URLResponse) throws -> HTTPURLResponse {
    guard let httpResponse = response as? HTTPURLResponse else {
        throw HTTPClientError.invalidURLResponseError(response)
    }
    if isErrorResponse(httpResponse) {
        throw HTTPClientError.invalidHTTPStatusCodeError(httpResponse)
    }
    return httpResponse
}

private func isErrorResponse(_ response: HTTPURLResponse) -> Bool {
    response.statusCode >= 400 && response.statusCode < 600
}

extension HTTPClientError {
    func map() -> ResponseErrorReason {
        switch self {
        case .URLSessionError(let error):
            .URLSessionError(error: error)
        case .invalidHTTPStatusCodeError(let response):
            .invalidHTTPStatusCode(response: response)
        case .invalidURLResponseError(let response):
            .invalidURLResponse(response: response)
        }
    }
}
