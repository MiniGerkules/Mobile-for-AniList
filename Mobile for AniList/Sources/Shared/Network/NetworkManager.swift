import Foundation

enum NetworkManager {
    enum NetworkError: Error {
        case unexpectedResponse(URLResponse)
        case failedResponse(URLResponse)
    }

    private static let httpSuccessCodes_ = 200..<300

    static func performRequest(
        _ request: URLRequest, session: URLSession = .shared
    ) async throws -> (Data, URLResponse) {
        return try await session.data(for: request)
    }

    static func performHTTPRequest(
        _ request: URLRequest, session: URLSession = .shared
    ) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await performRequest(request, session: session)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unexpectedResponse(response)
        }
        guard httpSuccessCodes_.contains(httpResponse.statusCode) else {
            throw NetworkError.failedResponse(response)
        }

        return (data, httpResponse)
    }

    static func loadData(from urls: [URL?]) async -> [Data?] {
        var images = [Data?](repeating: nil, count: urls.count)

        for (ind, url) in urls.enumerated() {
            guard let url else { continue }

            let request = URLRequestFactory.createRequest(to: url)
            let res = try? await performRequest(request)

            images[ind] = res?.0
        }

        return images
    }
}
