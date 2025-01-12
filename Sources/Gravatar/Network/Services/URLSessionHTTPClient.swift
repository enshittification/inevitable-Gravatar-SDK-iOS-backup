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
