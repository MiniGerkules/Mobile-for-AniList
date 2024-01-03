import SwiftUI

struct ContentList: View {
    let service: ContentListServiceProtocol

    @State private var contentType: MediaType = .anime

    @State private var canLoadMore: Bool = true
    @State private var needLoadData: Bool = false

    @State private var wasError: Bool = false

    var body: some View {
        content
            .onReceive(service.canLoadMore) {
                canLoadMore = $0
            }
            .onChange(of: needLoadData) {
                guard needLoadData else { return }

                needLoadData = false
                Task {
                    await service.loadMore()
                }
            }
            .onReceive(service.wasError) {
                wasError = true
            }
            .alert("Error", isPresented: $wasError) {
            } message: {
                Text(service.errorMsg)
            }
    }

    @MainActor
    private var content: some View {
        VStack {
            Picker("Content type", selection: $contentType) {
                ForEach(MediaType.allCases, id: \.self) { type in
                    Text(type.rawValue.capitalized)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: contentType) {
                service.updateContentType(contentType)
            }

            List {
                Group {
                    ForEach(service.contentList, id: \.title) {
                        ContentCard(content: $0)
                            .shadow(radius: 7)
                    }

                    if canLoadMore {
                        HStack {
                            Spacer()
                            LoadDataCell(needLoadData: $needLoadData)
                            Spacer()
                        }
                    }
                }
                .listRowInsets(.init())
                .listRowSeparator(.hidden)
                .padding()
            }
            .listStyle(.plain)
        }
    }
}

#Preview {
    return ContentList(service: ContentListServiceMock())
}
