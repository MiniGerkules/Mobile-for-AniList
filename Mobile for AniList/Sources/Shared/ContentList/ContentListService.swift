import Combine
import SwiftUI

@MainActor
protocol ContentListServiceProtocol {
    var canLoadMore: AnyPublisher<Bool, Never> { get }
    var wasError: AnyPublisher<Void, Never> { get }
    var errorMsg: String { get }

    var contentList: [ContentCardModel] { get }

    func loadMore() async
    func updateContentType(_ contentType: MediaType)
}

@MainActor
@Observable final class ContentListServiceImpl: ContentListServiceProtocol {
    private let canLoadMore_ = PassthroughSubject<Bool, Never>()
    var canLoadMore: AnyPublisher<Bool, Never> {
        canLoadMore_.eraseToAnyPublisher()
    }

    var errorMsg = ""
    private let wasError_ = PassthroughSubject<Void, Never>()
    var wasError: AnyPublisher<Void, Never> {
        wasError_.eraseToAnyPublisher()
    }

    deinit {
        canLoadMore_.send(completion: .finished)
        wasError_.send(completion: .finished)
    }

    var contentList: [ContentCardModel] {
        switch contentType {
        case .anime:
            animeList
        case .manga:
            mangaList
        }
    }

    private var contentType: MediaType = .anime

    private var animeList: [ContentCardModel] = []
    private var mangaList: [ContentCardModel] = []

    private var animeCurPage: Int = 1
    private var mangaCurPage: Int = 1
    private var currentPage: Int {
        get {
            switch contentType {
            case .anime:
                animeCurPage
            case .manga:
                mangaCurPage
            }
        }
        set {
            switch contentType {
            case .anime:
                animeCurPage = newValue
            case .manga:
                mangaCurPage = newValue
            }
        }
    }

    func updateContentType(_ contentType: MediaType) {
        self.contentType = contentType
    }

    func loadMore() async {
        let query = GetByScoreQuery(variables: .init(page: currentPage, type: contentType))
        defer { currentPage += 1 }

        let request = try? URLRequestFactory.graphQLRequest(to: baseURL, data: query.query)
        guard let request else { return }

        do {
            let (data, _) = try await NetworkManager.performHTTPRequest(request)
            await parseData(data: data)
        } catch {
            errorMsg = "Error of network request. Try later."
            wasError_.send()
        }
    }

    private func parseData(data: Data) async {
        do {
            let decoded = try JSONDecoder().decode(GetByScoreResponse.self, from: data)
            canLoadMore_.send(decoded.data.page.pageInfo.hasNextPage)

            addNewContent(decoded.data.page.media.map { title in
                ContentCardModel(
                    coverURL: title.coverImage.large,
                    title: title.title.userPreferred,
                    averageScore: title.averageScore
                )
            })
        } catch {
            errorMsg = "Error with data. Try later."
            wasError_.send()
        }
    }

    private func addNewContent(_ content: [ContentCardModel]) {
        switch contentType {
        case .anime:
            animeList.append(contentsOf: content)
        case .manga:
            mangaList.append(contentsOf: content)
        }
    }
}

@MainActor
@Observable final class ContentListServiceMock: ContentListServiceProtocol {
    var canLoadMore = PassthroughSubject<Bool, Never>().eraseToAnyPublisher()
    var wasError = PassthroughSubject<Void, Never>().eraseToAnyPublisher()
    var errorMsg = ""

    var contentList: [ContentCardModel] = [
        .init(coverURL: "https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx124194-pWfBqp3GgjOx.jpg", title: "Fruits Basket: The Final", averageScore: 90),
        .init(coverURL: "https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx104578-LaZYFkmhinfB.jpg", title: "Shingeki no Kyojin 3 Part 2", averageScore: 89),
        .init(coverURL: "https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx145064-5fa4ZBbW4dqA.jpg", title: "Jujutsu Kaisen 2nd Season", averageScore: 88),
    ]

    func updateContentType(_ contentType: MediaType) {
        switch contentType {
        case .anime:
            contentList = [
                .init(coverURL: "https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx124194-pWfBqp3GgjOx.jpg", title: "Fruits Basket: The Final", averageScore: 90),
                .init(coverURL: "https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx104578-LaZYFkmhinfB.jpg", title: "Shingeki no Kyojin 3 Part 2", averageScore: 89),
                .init(coverURL: "https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx145064-5fa4ZBbW4dqA.jpg", title: "Jujutsu Kaisen 2nd Season", averageScore: 88),
            ]
        case .manga:
            contentList = [
                .init(coverURL: "https://s4.anilist.co/file/anilistcdn/media/manga/cover/large/bx30002-7EzO7o21jzeF.jpg", title: "Berserk", averageScore: 93),
                .init(coverURL: "https://s4.anilist.co/file/anilistcdn/media/manga/cover/medium/b135129-rbQyUsPfUZTj.jpg", title: "Vagabond: Saigo no Manga-ten", averageScore: 88),
                .init(coverURL: "https://s4.anilist.co/file/anilistcdn/media/manga/cover/large/bx98610-TIf7R1gkU0vc.jpg", title: "86: Eighty Six", averageScore: 87)
            ]
        }
    }
    func loadMore() async { }
}

