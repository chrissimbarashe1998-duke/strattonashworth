struct iOS26StylesheetContentView: View {
    @State private var showSheet: Bool = false
    var body: some View {
        NavigationStack {
            List {
                Button("Show Sheet") {
                    showSheet = true
                }
            }
            .navigationTitle("iOS 26 Stylesheet")
        }
        .iOS26Sheet(minimumCornerRadius: 20, padding: 20, isPresented: $showSheet) {
            Text("HoneyBird")
                .presentationDetents([.height(100), .height(400), .fraction(0.99)])
                .presentationBackgroundInteraction(.enabled(upThrough: .height(400)))
        }
    }
}
            
extension View {
    @ViewBuilder func iOS26Sheet<SheetContent: View>(
        minimumCornerRadius: CGFloat,
        padding: CGFloat,
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> SheetContent
    ) -> some View {
        self
        .modifier(
            iOS26SheetModifier(
                minimumCornerRadius: minimumCornerRadius,
                padding: padding,
                isPresented: isPresented,
                sheetContent: sheetContent
            )
        )
    }
}

//somewhere in this code, instead of checking the cornerRadius for each time the 
// size changes, i can place that logic after the shadow update to make sure that the callback is only called once
//should ask AI where to place that logic exactly

fileprivate struct iOS26SheetModifier<SheetContent: View>: ViewModifier {
    var minimumCornerRadius: CGFloat
    var padding: CGFloat
    @Binding var isPresented: Bool
    @ViewBuilder var sheetContent: SheetContent
    @State private var progress: CGFloat = 0
    @State private var animationDuration: CGFloat = 0
    @State private var storedHeight: CGFloat = 0
    @State private var deviceCornerRadius: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented, onDismiss: {
                progress = 0
                animationDuration = 0
                storedHeight = 0
                }) {
                if #available(iOS 26.0, *) {
                    sheetContent
                } else {
                    let padding = padding * (1 - progress)
                    let cornerRadius = deviceCornerRadius - padding

                    GeometryReader { _ in  
                        sheetContent
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .compositingGroup()
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    .background {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(.background)
                            
                    }
                    .padding([.horizontal, .bottom], padding)
                    .animation(.easeInOut(duration: animationDuration), value: progress)
                    .presentationCornerRadius(cornerRadius)
                    .presentationBackground(
                        .clear
                    )
                    .background(
                        SheetHelper { radius in
                            deviceCornerRadius = max(radius, minimumCornerRadius)
                        } height: { height in
                            let maxHeight = windowSize.height * 0.7
                            let progress = max(0, min(1, (height.rounded() / maxHeight)))
                            self.progress = progress

                            //CALCULATING ANIMATION DUration
                            let diff = abs(height - storedHeight)
                            let duration = max(min(diff / 100, 0.22), 0)
                            if diff > 10 && storedHeight != 0 {
                                animationDuration = duration
                            }

                            storedHeight = height
                        }
                    )
                    .ignoresSafeArea(.all, edges: .bottom)
                    .persistentSystemOverlays(.hidden)
                }
            }
    }

    private var windowSize: CGSize {
        if let screen = 
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen {
            return screen.bounds.size
        }

        return .zero
    }
}

fileprivate struct SheetHelper: UIViewRepresentable {
    var cornerRadius: (CGFloat) -> Void
    var height: (CGFloat) -> Void

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            if let layer = view.superview?.superview?.superview?.layer {
                cornerRadius(layer.cornerRadius)
            }
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if !context.coordinator.isShadowRemoved {
            DispatchQueue.main.async {
                if let shadowView = uiView.dropShadowView {
                    shadowView.layer.shadowColor = UIColor.clear.cgColor
                    context.coordinator.isShadowRemoved = true
                }
            }
        } else { 

        }
    }

    func sizeThatFits(
        _ proposal: ProposedViewSize,
        uiView: UIView,
        context: Context
    ) -> CGSize? {
        if let layer = uiView.superview?.superview?.superview?.layer {
                cornerRadius(layer.cornerRadius)
        }

        if let height = proposal.height {
            self.height(height)
        }

        return nil
    }

    class Coordinator: NSObject {
        var isShadowRemoved: Bool = false
    }
    
}

fileprivate extension UIView {
    var dropShadowView: UIView? {
        if let superview, String(describing: type(of: superview)).== "UIDropShadowView" {
            return superview
        }

        return superview?.dropShadowView
    }
}