import Foundation

struct Coffee: Identifiable {
    let id: UUID
    let title: String
    let imageNaame: String
    let price: String
}

let coffees: [Coffee] = [
    Coffee(id: UUID(), title: "Espresso", imageNaame: "espresso", price: "$3.99"),
    Coffee(id: UUID(), title: "Cappuccino", imageNaame: "cappuccino", price: "$4.49"),
    Coffee(id: UUID(), title: "Latte", imageNaame: "latte", price: "$4.99"),
    Coffee(id: UUID(), title: "Americano", imageNaame: "americano", price: "$3.49"),
    Coffee(id: UUID(), title: "Mocha", imageNaame: "mocha", price: "$5.49"),
    Coffee(id: UUID(), title: "Macchiato", imageNaame: "macchiato", price: "$4.99"),
    Coffee(id: UUID(), title: "Cold Brew", imageNaame: "coldbrew", price: "$4.99"),
    Coffee(id: UUID(), title: "Flat White", imageNaame: "flatwhite", price: "$4.49"),
    Coffee(id: UUID(), title: "Irish Coffee", imageNaame: "irish", price: "$6.99"),
    Coffee(id: UUID(), title: "Turkish Coffee", imageNaame: "turkish", price: "$4.99")
]

import SwiftUI

struct CoffeeHome: View {
    @State var offsetY: CGFloat = 0
    @State var currentIndex: CGFloat = 0
    var body: some View {
        GeometryReader { 
            let size = $0.size
            let cardSize = size.width * 0.8

            LinearGradient(colors: [Color.brown.opacity(0.2), Color.brown.opacity(0.45), Color.brown], startPoint: .top, endPoint: .bottom)
                .frame(height: 300)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .ignoresSafeArea()

                HeaderView()

            VStack(spacing: 0) {
                ForEach(coffees) { coffee in
                    coffeeview(coffee: coffee, size: size)
                        
                }
            }
            .frame(width: size.width)
            .padding(.top, size.height - cardSize)
            .offset(y: offsetY)
            .offset(y: -currentIndex * cardSize)
        }
        .coordinateSpace(name: "SCROLL")
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .onchanged ({ value in
                    offsetY = value.translation.height * 0.4 //multiply by 0.4 to slow down the gestures
                }).onEnded ({ value in
                    let translation = value.translation.height

                    if translation > 0 {
                        if currentIndex > 0 && translation > 250 {
                            currentIndex -= 1
                        }
                    } else {
                        if currentIndex < CGFloat(coffees.count - 1) && -translation > 250 {
                            currentIndex += 1
                        }
                    }

                    offsetY = .zero
                })
        )
        
    }

    @ViewBuilder func HeaderView() -> some View {
        //Animated Slider

        GeometryReader {
            let size = $0.size

            HStack(spacing: 0) {
                ForEach(coffees) { coffee in
                    VStack(spacing: 15) {
                        Text(coffee.title)
                            .font(.title.bold())
                            .multilineTextAlignment(.center)
                        Text(coffee.price)
                            .font(.title2.bold())
                    }
                    .frame(width: size.width)
                }
            }
            .offset(x: currentIndex * -size.width)
            .animation(.interactiveSpring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.8), value: currentIndex)
        }
        .padding(.top, -5)
    }
}

struct CoffeeHome_Previews: PreviewProvider {
    static var previews: some View {
        CoffeeHome()
    }
}

struct CoffeeContentView: View {
    var body: some View {
        CoffeeHome()
    }
}

struct CoffeeContentView_Previews: PreviewProvider {
    static var previews: some View {
        CoffeeContentView()
    }
}

struct coffeeview: View {
    var coffee: Coffee
    var size: CGSize

    var body: some View {
        let cardSize = size.width * 0.8 //size of the image

        let maxCardsDisplaySize = size.width * 4
        GeometryReader{ geometry in 
        let _size = geometry.size

        //current card offset
        let offset = geometry.frame(in: .named("SCROLL")).minY - (size.height - cardSize) 
        let scale = offset <= 0 ? (offset / maxCardsDisplaySize) : 0
        let reducedScale = 1 + scale
        let currentCardScale = offset / cardSize

        Image(coffee.imageNaame)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: _size.width, height: _size.height)
        .scaleEffect(reducedScale < 0 ? 0.001 : reducedScale, anchor: .init(x: 0.5, y: 1 - (currentCardScale / 2.4))
        .scaleEffect(offset > 0 ? 1 + currentCardScale : 1, anchor: .top)
        .offset(y: offset > 0 ? currentCardScale * 200 : 0)
        //making it more compact
        .offset(Y: currentCardScale * -130)
        }
        .frame(height: cardSize)
    }
}

struct coffeeview_Previews: PreviewProvider {
    static var previews: some View {
        coffeeview(coffee: coffees.first!, size: CGSize(width: 120, height: 90))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
