//MARK: - Query

struct GetByScoreQuery: GraphQLQuery {
    let variables: GetByScoreVariables

    var query: GraphQLRequestContainer<String, GetByScoreVariables> {
        .init(
            query: """
                query($page: Int!, $perPage: Int, $type: MediaType, $sortOrder: [MediaSort]) {
                    Page(page: $page, perPage: $perPage) {
                        pageInfo {
                            perPage
                            currentPage
                            hasNextPage
                        }
                        media(type: $type, sort: $sortOrder) {
                            title {
                                userPreferred
                            }
                            averageScore
                            coverImage {
                                extraLarge
                                large
                                medium
                                color
                            }
                        }
                    }
                }
                """,
            variables: variables
        )
    }
}

struct GetByScoreVariables: Encodable {
    /// Number of content page
    let page: Int

    /// Number of content on a page
    let perPage: Int

    /// Type of content
    let type: MediaType

    /// A set of descriptors to sort
    let sortOrder: [MediaSort]

    init(
        page: Int,
        perPage: Int = 20,
        type: MediaType = .anime,
        sortOrder: [MediaSort] = [.scoreDesc]
    ) {
        self.page = page
        self.perPage = perPage
        self.type = type
        self.sortOrder = sortOrder
    }
}

enum MediaType: String, Encodable, CaseIterable {
    case anime = "ANIME"
    case manga = "MANGA"
}

enum MediaSort: String, Encodable {
    case scoreAsc = "SCORE"
    case scoreDesc = "SCORE_DESC"
}


//MARK: - Response

struct GetByScoreResponse: Decodable {
    let data: GraphQLData
}

struct GraphQLData: Decodable {
    let page: GraphQLPage

    enum CodingKeys: String, CodingKey {
        case page = "Page"
    }
}

struct GraphQLPage: Decodable {
    let pageInfo: GraphQLPageInfo
    let media: [GraphQLMedia]
}

struct GraphQLPageInfo: Decodable {
    let perPage: Int
    let currentPage: Int
    let hasNextPage: Bool
}

struct GraphQLMedia: Decodable {
    let title: GraphQLTitle
    let averageScore: Int
    let coverImage: GraphQLCoverImage
}

struct GraphQLTitle: Decodable {
    let userPreferred: String
}

struct GraphQLCoverImage: Decodable {
    let large: String
}
