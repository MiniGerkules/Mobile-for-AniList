import SwiftUI

struct LoadDataCell: View {
    @Binding var needLoadData: Bool

    var body: some View {
        ProgressView().onAppear {
            needLoadData = true
        }
    }
}

#Preview {
    @State var needLoadData = false

    return LoadDataCell(needLoadData: $needLoadData)
}
