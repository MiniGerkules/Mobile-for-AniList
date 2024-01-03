import Foundation

enum URLRequestFactory {
    static func createRequest(
        to url: URL, timeout: TimeInterval = 10
    ) -> URLRequest {
        let request = URLRequest(
            url: url,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: timeout
        )

        return request
    }

    static func graphQLRequest(
        to url: URL, data: Data, timeout: TimeInterval = 10
    ) -> URLRequest {
        var request = createRequest(to: url, timeout: timeout)

        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = data

        return request
    }

    static func graphQLRequest<Q: Encodable, V: Encodable>(
        to url: URL, data: GraphQLRequestContainer<Q, V>, timeout: TimeInterval = 10
    ) throws -> URLRequest {
        let encoded = try JSONEncoder().encode(data)

        return graphQLRequest(to: url, data: encoded, timeout: timeout)
    }
}
