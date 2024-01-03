import SwiftUI

struct ContentCard: View {
    let content: ContentCardModel

    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: content.coverURL)) { phase in
                    Group {
                        if let image = phase.image {
                            image.resizable()
                        } else {
                            Image("placeholder").resizable()
                        }
                    }
                    .scaledToFit()
                }

                ZStack {
                    Circle()
                        .frame(width: 40, height: 40)
                        .foregroundStyle(.white)

                    Text(String(content.averageScore))
                        .fontWeight(.bold)
                }
                .padding()
            }

            Text(content.title)
                .font(.headline)
                .padding()
        }
        .background()
        .clipShape(.rect(cornerRadius: 20))
    }
}

#Preview {
    VStack {
        ContentCard(content:
            .init(
                coverURL: "https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx145064-5fa4ZBbW4dqA.jpg",
                title: "Jujutsu Kaisen 2nd Season",
                averageScore: 88
            )
        )
        .padding()
        .shadow(radius: 20)

        Spacer()
    }
}
