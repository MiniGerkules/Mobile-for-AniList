import SwiftUI

struct MainScreen: View {
    var body: some View {
        TabView {
            ContentList(service: ContentListServiceImpl())
                .tabItem { Label("Top", systemImage: "list.number") }
        }
    }
}

#Preview {
    MainScreen()
}
