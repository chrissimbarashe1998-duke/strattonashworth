//remote is https://github.com/chrissimbarashe1998-duke/strattonashworth.git

struct segementedControl: View {
    @State private var selectedTab: Tab = .all
    @State private var textWidth: CGFloat = 0
    @State private var textWidths: [CGFloat] = Array(repeating: 0, count: Tab.allCases.count)
    @State var indexInt: CGFloat = 0
    @State var hStackWidth: CGFloat = 0

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(Tab.allCases.indices, id: \.self) { index in
                    let tab = Tab.allCases[index]
                    Text(tab.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .background(
                            GeometryReader(content: { textGeoWidth -> Color in
                                DispatchQueue.main.async {
                                    textWidths[index] = textGeoWidth.size.width
                                }
                                return Color.clear
                            })
                        )
                        .foregroundColor(selectedTab == tab ? .black : .gray)
                        .onTapGesture {
                            withAnimation(.spring()) {
                                indexInt = CGFloat(index)
                                textWidth = textWidths[index]
                                selectedTab = tab
                                
                            }
                        }
                }
            }
            .background(
                GeometryReader(content: { geometry in 
                    Capsule()
                    .foregroundStyle(.gray.opacity(0.3))
                    .frame(width: textWidth + 30)
                    .offset(x: indexInt * 100)
                    .offset(x: -15)
                })
            )
        }
    }

}

    enum Tab: String, CaseIterable {
        case all = "All"
        case favorites = "Favorites"
        case recent = "Recent"
        case trending = "Trending"
        case fiction = "Fiction
        case nonfiction = "Non-Fiction"
        case mystery = "Mystery"
        case romance = "Romance"
        case action = "Action"
        case comedy = "Comedy"
    }
}