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
            //MARK: Since card size is the size of the screen width

            let cardSize = size.width

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
        GeometryReader{ geometry in 
        let size = geometry.size

        Image(coffee.imageNaame)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: size.width, height: size.height)
        }
        .frame(height: size.width)
    }
}

struct coffeeview_Previews: PreviewProvider {
    static var previews: some View {
        coffeeview(coffee: coffees.first!, size: CGSize(width: 120, height: 90))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
