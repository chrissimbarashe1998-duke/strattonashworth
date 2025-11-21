fileprivate struct CustomPickerView: View {
    var texts: [String]
    @Binding var config: PickerConfig
    @State private var activeText: String?
    @State private var showContent: Bool = false
    @State private var shwoScrollView: Bool = false
    @State private var expandItems: Bool = false
    var body: some View {
        GeometryReader {
            let size = $0.size

            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(showContent ? 1 : 0)
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(texts, id: \.self) { text in
                            CardView(text, size: size)
                            
                        }
                    }
                    .scrollTargetLayout()
                }
                .safeAreaPadding(.top, (size.height * 0.5) - 20)
                .safeAreaPadding(.bottom, (size.height * 0.5))
                .scrollPosition(id: $activeText, anchor: .center) //center because the picker begins and ends at that location
                .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
                .scrollIndicators(.hidden)
                .opacity(shwoScrollView ? 1 : 0)
                .allowsHitTesting(shwoScrollView && expandItems)

                let offset: CGSize = .init( 
                    width: showContent ? size.width * -0.3 : config.sourceFrame.minX,
                    height: showContent ? -10 : config.sourceFrame.minY 
                )

                Text(config.text)
                    .fontWeight(showContent ? .semibold : .regular)
                    .foregroundStyle(.pink)
                    .frame(height: 20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: showContent ? .trailing : .topLeading)
                    .offset(offset)
                    .opacity(showScrollView ? 0 : 1)
                    .ignoresSafeArea(.all, edges: showContent ? [] : .all)

                    CloseButton()
        }
        .task {
            guard activeText == nil else { return }
            activeText = config.text
            withAnimation(.easeInOut(duration: 0.3)) {
                showContent = true
            }

            try? await Task.sleep(for: .seconds(0.3))
            shwoScrollView = true

            withAnimation(.snappy(duration: 0.3, extraBounce: 0)) {
                expandItems = true
            }
        }
        .onChange(of: activeText) { oldValue, newValue in
            if let newValue {
                config.text = newValue
            }
        }
        
    }

    @ViewBuilder func CloseButton() -> some View {
        Button {
            Task {
                //1. minimize all the elements
                withAnimation(.easeInOut(duration: 0.2)) {
                    expandItems = false
                }

                try? await Task.sleep(for: .seconds(0.2))
                //2. hide scrollview and palcing the active item back to its sosurce position
                shwoScrollView = false
                withAnimation(.easeInOut(duration: 0.3)) {
                    showContent = false
                }

                try? await Task.sleep(for: .seconds(0.2))

                //3. finally closing the overlay view
                config.show = false
            }
        } label: {
            Image(systemName: "xmark")
                .font(.title2)
                .foregroundStyle(.primary)
                .frame(width: 45, height: 45)
                .contentShape(Rectangle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
        .offset(x: expandItems ? -50 : 50, y: -10)
    }

    @ViewBuilder func CardView(_ text: String, size: CGSize) -> some View {
        GeometryReader { proxy  in 
        let width = proxy.size.width

            Text(text)
            .fontWeight(.semibold)
            .foregroundStyle(config.text == text ? .pink : .gray)
            .offset(y: offset(proxy))
            .opacity(expandItems ? 1 : config.text == text ? 1 : 0)
            .clipped()
            .offset(x: -width * 0.3) //-width for trailing edge, + for leading edge
            .rotationEffect(.init(degrees: expandItems ? -rotation(proxy, size) : .zero), anchor: .topTrailing) //-rotation for trailing edge, + and topLeading for leading edge
            .opacity(opacity(proxy, size: size))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing) //leading for leading edge, trailing for trailing edge
        }
        .frame(height: 20)
        .lineLimit(1)
    }

    private func offset(_ proxy: GeometryProxy) -> CGFloat {
            let minY = proxy.frame(in: .scrollView(axis: .vertical)).minY
            return expandItems ? 0 : -minY
    }

    private func rotation(_ proxy: GeometryProxy, _ size: CGSize) -> CGFloat {
            let height =  size.height * 0.5 
            let minY = proxy.frame(in: .scrollView(axis: .vertical)).minY
            let maxRotation: CGFloat = 220
            let progress = minY / height
            return progress * maxRotation
    }

    private func opacity(_ proxy: GeometryProxy, size: CGSize) -> CGFloat {
        let minY = proxy.frame(in: .scrollView(axis: .vertical)).minY
        let height = size.height * 0.5
        let progress = (minY / height) * 2.8 
        let opacity = progress < 0 ? 1 + progress : 1 - progress

        return opacity
    }
}

let pickerValues: [String] = [
    "SwiftUI",
    "Kotlin",
    "Java",
    "JavaScript",
    "Python",
    "C++",
    "C#",
    "Ruby",
    "Go",
    "Rust",
    "Dart",
    "PHP",
    "TypeScript",
    "HTML",
    "CSS",
    "SQL",
    "Perl",
    "Haskell",
    "Lua",
    "MATLAB"
]

let pickerValues1: [String] = [
    "iOS 17+ Projects",
    "iOS 16- Projects",
    "macOS Projects",
    "tvOS Projects",
    "watchOS Projects",
    "Cross-Platform Projects",
    "Swift Packages",
    "Server-Side Swift",
    "Swift Playgrounds",
    "Swift for TensorFlow"
]

struct CustomPickerContentView: View {
    @State private var config: PickerConfig = PickerConfig(text: "SwiftUI")
    @State private var config1: PickerConfig = PickerConfig(text: "iOS 17+ Projects")
    var body: some View {
        NavigationStack {
            List {
                Section("Configuration") {
                    Button {
                        config.show.toggle()
                    } label: {
                        HStack {
                            Text("Select Language")
                            Spacer(minLength: 0)
                            SourcePickerView(config: $config)
                        }
                    }

                     Button {
                        config1.show.toggle()
                    } label: {
                        HStack {
                            Text("Select Project")
                            Spacer(minLength: 0)
                            SourcePickerView(config: $config1)
                        }
                    }
                }
            }
            .navigationTitle("Custom Picker")
        }
        .customPicker($config, items: pickerValues) //neds to be used in the root of the app
        .customPicker($config1, items: pickerValues1)
    }
}

extension View {
    @ViewBuilder func customPicker(_ config: Binding<PickerConfig>, items: [String]) -> some View {
        self
        .overlay {
            if config.wrappedValue.show {
                CustomPickerView(texts: items, config: config)
                .transition(.identity)
            }
        }
    }
}

struct CustomPicker: View {
    var body: some View {
        
    }
}

struct PickerConfig {
    var text: String
     init(text: String) {
        self.text = text
     }

     var show: Bool = false

     var sourceFrame: CGRect = .zero //used for custom matched geometry effect
}

struct SourcePickerView: View {
    @Binding var config: PickerConfig
    var body: some View {
        Text(config.text)
        .foregroundStyle(.blue)
        .frame(height: 20)
        .opacity(config.show ? 0 : 1)
        .onGeometryChange(for: CGSize.self) { proxy in
            proxy.frame(in: .global)
        } action: {  newValue in 
            config.sourceFrame = newValue  
        }
    }
}