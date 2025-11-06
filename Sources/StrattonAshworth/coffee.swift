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
    var body: some View {
        NavigationView {
            List(coffees) { coffee in
                HStack(spacing: 12) {
                    Image(coffee.imageNaame)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 56, height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(coffee.title)
                            .font(.headline)
                        Text(coffee.price)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 6)
            }
            .navigationTitle("Coffee")
        }
    }
}

struct CoffeeHome_Previews: PreviewProvider {
    static var previews: some View {
        CoffeeHome()
    }
}