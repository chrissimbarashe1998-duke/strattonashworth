//remote is https://github.com/chrissimbarashe1998-duke/strattonashworth.git

struct segementedControl: View {
    @Binding var selectedTab: Tab
    @State private var textWidth: CGFloat = 0
    @State private var textWidths: [CGFloat] = Array(repeating: 0, count: Tab.allCases.count)
    @State var indexInt: CGFloat = 0
    @State var hStackWidth: CGFloat = 0

    var body: some View {
        ScrollViewReader { proxy in 
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
                        .id(index)
                        .frame(width: 70, alignment: .leading)
                        .padding(.vertical, 10)
                        .foregroundColor(selectedTab == tab ? .black : .gray)
                        .onTapGesture {
                            withAnimation(.spring()) {
                                indexInt = CGFloat(index)
                                textWidth = textWidths[index]
                                selectedTab = tab
                                
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 {
                                withAnimation {
                                    proxy.scrollTo(index, anchor: .center)
                                }
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
            .padding(.horizontal, 15)
            .onAppear {
                if textWidth == 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        textWidth = textWidths[0]
                    }
                }
            }
        }
        }
    }

}

enum Tab: String, CaseIterable {
        case all = "All"
        case favorites = "Favorites"
        case recent = "Recent"
        case trending = "Trending"
        case fiction = "Fiction"
        case nonfiction = "Non-Fiction"
        case mystery = "Mystery"
        case romance = "Romance"
        case action = "Action"
        case comedy = "Comedy"
}

struct Books:View{
    var book: Book
    var body: some View {
        Image(book.imageName)
            .resizable()
            .scaledToFill()
            .frame(width: 176, height: 260)
            .clipShape(.rect(cornerRadius: 10))
            .overlay(alignment: .bottom) {
                UnevenRoundedRectangle(bottomLeadingRadius: 12, bottomTrailingRadius: 12)
                .frame(height: 40)
                .foregroundStyle(LinearGradient(colors: [.black.opacity(0.8), .black.opacity(0.3), .black.opacity(0.1), .clear], startPoint: .leading, endPoint: .trailing))

                Text(book.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.leading, 10)
                    .padding(.bottom, 5)
                    .frame(width: 140, alignment: .leading)
            }
            .overlay(alignment: .topTrailing) {
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("\(String(format: "%.1f", book.rating))")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                .offset(x: -1) 
                .font(.system(size: 14))
                .frame(width: 50, height: 24)
                .background(.white, in: RoundedRectangle(cornerRadius: 12))
                .padding(12)
            }
    }
}

struct BookView: View {
    @Binding var selectedTab: Tab
    var vm = DataManager.shared
    var currentBooks: [Book] {
        if let category = vm.categories.first(where: { $0.name.lowercased() == selectedTab.rawValue.lowercased }) {
            return category.books
        } else {  
            return vm.categories.first?.books ?? []
        }

    }

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(), count: 2), content: {
            ForEach(currentBooks, id: \.title) { book in
                NavigationLink(destination: SelectedView(book: book)) {
                    Books(book: book)
                }
            }
}

struct Category {
    var name: String
    var books: [Book]
}

struct Book {
    var title: String
    var imageName: String
    var rating: Double
    var description: String
    var story: String
}

class DataManager {
    static let shared = DataManager()
    
    // Create categories array from tabs (excluding "All", "Favorites", "Recent", "Trending" as they are more like filters)
let categories: [Category] = [
    Category(name: "Fiction", books: [
        Book(title: "To Kill a Mockingbird", imageName: "mockingbird", rating: 4.8, description: "A gripping tale of racial injustice and childhood innocence in the American South.", story: "Set in the fictional town of Maycomb, Alabama, during the Great Depression, the novel explores the experiences of young Scout Finch as her father, Atticus, defends a Black man falsely accused of rape."),
        Book(title: "1984", imageName: "nineteen-eighty-four", rating: 4.7, description: "A dystopian social science fiction novel about totalitarian control.", story: "Winston Smith lives in a world of constant surveillance and thought control under Big Brother's regime, where the Ministry of Truth rewrites history and love is forbidden."),
        Book(title: "Pride and Prejudice", imageName: "pride-and-prejudice", rating: 4.6, description: "A romantic novel of manners set in Georgian England.", story: "Elizabeth Bennet must navigate issues of manners, upbringing, morality, education, and marriage as she encounters the proud and wealthy Mr. Darcy."),
        Book(title: "The Great Gatsby", imageName: "great-gatsby", rating: 4.5, description: "A classic American novel about the Jazz Age and the American Dream.", story: "Nick Carraway narrates the story of his neighbor Jay Gatsby and his obsession with the beautiful Daisy Buchanan in 1920s Long Island."),
        Book(title: "Harry Potter and the Sorcerer's Stone", imageName: "harry-potter", rating: 4.9, description: "A young wizard discovers his magical heritage and begins his journey at Hogwarts School.", story: "Harry Potter, an orphan living with his cruel relatives, discovers on his eleventh birthday that he is a wizard and enrolls at Hogwarts School of Witchcraft and Wizardry.")
    ]),
    
    Category(name: "Non-Fiction", books: [
        Book(title: "Sapiens: A Brief History of Humankind", imageName: "sapiens", rating: 4.7, description: "An exploration of human history from the Stone Age to the present.", story: "Yuval Noah Harari traces the history of humanity from the emergence of Homo sapiens in Africa to the present day, examining how our species has dominated the planet."),
        Book(title: "The Diary of a Young Girl", imageName: "anne-frank", rating: 4.8, description: "The personal diary of a Jewish girl hiding from the Nazis during World War II.", story: "Anne Frank's personal account of her life in hiding in Amsterdam during the Nazi occupation, revealing her thoughts, fears, and dreams."),
        Book(title: "Steve Jobs", imageName: "steve-jobs", rating: 4.6, description: "A biography of the Apple co-founder by Walter Isaacson.", story: "The authorized biography of Steve Jobs, exploring his life from his adoption and early interest in electronics to his role in revolutionizing multiple industries."),
        Book(title: "Becoming", imageName: "becoming", rating: 4.7, description: "Michelle Obama's memoir about her life and experiences as First Lady.", story: "The former First Lady shares her journey from her childhood in Chicago to her years in the White House, offering insights into her values and experiences."),
        Book(title: "Educated", imageName: "educated", rating: 4.8, description: "A memoir about a woman who leaves her survivalist family to pursue education.", story: "Tara Westover's account of growing up in a strict Mormon family and her journey to education and self-discovery.")
    ]),
    
    Category(name: "Mystery", books: [
        Book(title: "Gone Girl", imageName: "gone-girl", rating: 4.5, description: "A psychological thriller about a husband suspected of his wife's disappearance.", story: "Nick Dunne becomes the prime suspect when his wife Amy disappears on their wedding anniversary, but nothing is as it seems in this twisted tale of deception."),
        Book(title: "The Girl with the Dragon Tattoo", imageName: "dragon-tattoo", rating: 4.4, description: "A journalist and a hacker investigate a decades-old disappearance.", story: "Swedish journalist Mikael Blomkvist and hacker Lisbeth Salander investigate the mysterious disappearance of a young girl that occurred forty years earlier."),
        Book(title: "The Da Vinci Code", imageName: "da-vinci-code", rating: 4.3, description: "A symbologist investigates a murder in the Louvre Museum.", story: "Robert Langdon must solve a series of puzzles and codes while being pursued by the police, uncovering secrets about the Catholic Church and the Holy Grail."),
        Book(title: "Big Little Lies", imageName: "big-little-lies", rating: 4.6, description: "A mystery about three women whose lives unravel at their children's school.", story: "The story follows three women living in Monterey, California, whose lives become intertwined through their children's school, culminating in a tragic event."),
        Book(title: "The Silent Patient", imageName: "silent-patient", rating: 4.7, description: "A psychotherapist becomes obsessed with treating a woman who murdered her husband and then never spoke again.", story: "Alicia Berenson shot her husband and has not spoken since. Theo Faber, a psychotherapist, is determined to get her to talk.")
    ]),
    
    Category(name: "Romance", books: [
        Book(title: "The Notebook", imageName: "notebook", rating: 4.6, description: "A timeless love story about an elderly man reading to his wife with dementia.", story: "An elderly man reads to his wife with dementia, recounting the story of Noah and Allie's first love, separation, and reunion against the backdrop of social differences."),
        Book(title: "Pride and Prejudice", imageName: "pride-and-prejudice", rating: 4.6, description: "A romantic novel of manners set in Georgian England.", story: "Elizabeth Bennet must navigate issues of manners, upbringing, morality, education, and marriage as she encounters the proud and wealthy Mr. Darcy."),
        Book(title: "Outlander", imageName: "outlander", rating: 4.7, description: "A WWII nurse travels back in time to 18th century Scotland.", story: "Claire Randall finds herself transported back to 1743 Scotland where she encounters the dashing Highland warrior Jamie Fraser."),
        Book(title: "Me Before You", imageName: "me-before-you", rating: 4.5, description: "A young woman becomes a caregiver for a paralyzed man.", story: "Louisa Clark takes a job caring for Will Traynor, a quadriplegic man who lost his will to live after a motorcycle accident."),
        Book(title: "The Time Traveler's Wife", imageName: "time-travelers-wife", rating: 4.4, description: "A love story complicated by a man's involuntary time travel.", story: "Henry DeTamble, an accidental time traveler, struggles to maintain his relationship with his wife Clare as his unpredictable time travel creates challenges for their marriage.")
    ]),
    
    Category(name: "Action", books: [
        Book(title: "The Bourne Identity", imageName: "bourne-identity", rating: 4.5, description: "An amnesiac man discovers he's a highly trained assassin.", story: "Jason Bourne suffers from extreme memory loss and must discover his true identity while being hunted by those who want him dead."),
        Book(title: "The Hunger Games", imageName: "hunger-games", rating: 4.7, description: "A dystopian novel about a televised fight to the death.", story: "Katniss Everdeen volunteers to take her sister's place in the annual Hunger Games, a televised competition where teenagers fight to the death."),
        Book(title: "Jurassic Park", imageName: "jurassic-park", rating: 4.6, description: "Scientists clone dinosaurs and create a theme park with disastrous results.", story: "A wealthy entrepreneur creates a theme park populated by cloned dinosaurs, but when the security system fails, the park's visitors must survive the prehistoric predators."),
        Book(title: "The Hunt for Red October", imageName: "red-october", rating: 4.4, description: "A Soviet submarine captain attempts to defect to the United States.", story: "Captain Marko Ramius plans to defect with his nuclear submarine, while both Soviet and American forces pursue him across the Atlantic."),
        Book(title: "The Matrix", imageName: "matrix", rating: 4.3, description: "A hacker discovers reality is a computer simulation.", story: "Neo discovers that reality as he knows it is a computer simulation and joins a rebellion to free humanity from the machines that control them.")
    ]),
    
    Category(name: "Comedy", books: [
        Book(title: "The Hitchhiker's Guide to the Galaxy", imageName: "hitchhikers-guide", rating: 4.7, description: "An absurd comedy about a man's journey through space.", story: "Arthur Dent is rescued by his friend Ford Prefect just as Earth is destroyed to make way for a hyperspace bypass, leading to an intergalactic adventure."),
        Book(title: "Bridget Jones's Diary", imageName: "bridget-jones", rating: 4.3, description: "A single woman's humorous take on life and relationships.", story: "Bridget Jones navigates the challenges of single life in London while keeping a diary of her experiences, weight, and love life."),
        Book(title: "Confessions of a Shopaholic", imageName: "shopaholic", rating: 4.2, description: "A young woman's shopping addiction leads to financial chaos.", story: "Rebecca Bloomwood's shopping addiction leads her to rack up massive credit card debt while she works as a financial journalist."),
        Book(title: " Bridget Jones: The Edge of Reason", imageName: "bridget-jones-2", rating: 4.1, description: "Bridget's romantic adventures continue in this sequel.", story: "Bridget travels to Thailand and then back to London, where she navigates relationships and career challenges with her characteristic humor."),
        Book(title: "Eleanor Oliphant Is Completely Fine", imageName: "eleanor-oliphant", rating: 4.6, description: "A socially awkward woman's life begins to change.", story: "Eleanor Oliphant leads an isolated life with very little routine until a chance encounter changes everything.")
    ])
]

// Most Read Books array
let mostReadBooks: [Book] = [
    Book(title: "To Kill a Mockingbird", imageName: "mockingbird", rating: 4.8, description: "A gripping tale of racial injustice and childhood innocence in the American South.", story: "Set in the fictional town of Maycomb, Alabama, during the Great Depression, the novel explores the experiences of young Scout Finch as her father, Atticus, defends a Black man falsely accused of rape."),
    Book(title: "1984", imageName: "nineteen-eighty-four", rating: 4.7, description: "A dystopian social science fiction novel about totalitarian control.", story: "Winston Smith lives in a world of constant surveillance and thought control under Big Brother's regime, where the Ministry of Truth rewrites history and love is forbidden."),
    Book(title: "Pride and Prejudice", imageName: "pride-and-prejudice", rating: 4.6, description: "A romantic novel of manners set in Georgian England.", story: "Elizabeth Bennet must navigate issues of manners, upbringing, morality, education, and marriage as she encounters the proud and wealthy Mr. Darcy."),
    Book(title: "The Great Gatsby", imageName: "great-gatsby", rating: 4.5, description: "A classic American novel about the Jazz Age and the American Dream.", story: "Nick Carraway narrates the story of his neighbor Jay Gatsby and his obsession with the beautiful Daisy Buchanan in 1920s Long Island."),
    Book(title: "Harry Potter and the Sorcerer's Stone", imageName: "harry-potter", rating: 4.9, description: "A young wizard discovers his magical heritage and begins his journey at Hogwarts School.", story: "Harry Potter, an orphan living with his cruel relatives, discovers on his eleventh birthday that he is a wizard and enrolls at Hogwarts School of Witchcraft and Wizardry."),
    Book(title: "The Catcher in the Rye", imageName: "catcher-in-rye", rating: 4.4, description: "A coming-of-age novel about a teenager's journey through New York City.", story: "Sixteen-year-old Holden Caulfield is expelled from prep school and spends three days wandering around New York City, struggling with identity and belonging."),
    Book(title: "Lord of the Rings: The Fellowship of the Ring", imageName: "lord-of-rings", rating: 4.8, description: "A hobbit embarks on a quest to destroy a powerful ring.", story: "Frodo Baggins inherits a ring from his cousin Bilbo and, guided by the wizard Gandalf, sets out on a quest to destroy the One Ring in the fires of Mount Doom."),
    Book(title: "The Hobbit", imageName: "hobbit", rating: 4.7, description: "A hobbit's unexpected journey to reclaim treasure from a dragon.", story: "Bilbo Baggins is swept into an epic quest by the wizard Gandalf and thirteen dwarves to reclaim treasure from the fearsome dragon Smaug."),
    Book(title: "Brave New World", imageName: "brave-new-world", rating: 4.5, description: "A dystopian novel about a controlled society.", story: "In a futuristic world where people are genetically bred and psychologically conditioned, individuality and freedom are sacrificed for stability and happiness."),
    Book(title: "The Alchemist", imageName: "alchemist", rating: 4.6, description: "A shepherd boy's journey to find treasure in Egypt.", story: "Santiago, a young shepherd, follows his dreams to find treasure near the Egyptian pyramids, learning about the importance of pursuing one's Personal Legend."),
    Book(title: "Wuthering Heights", imageName: "wuthering-heights", rating: 4.3, description: "A tale of passionate love that transcends death.", story: "Heathcliff and Catherine Earnshaw's intense, destructive love affair affects the lives of their children and neighbors across two generations."),
    Book(title: "Jane Eyre", imageName: "jane-eyre", rating: 4.7, description: "A governess falls in love with her mysterious employer.", story: "Jane Eyre, an orphan, becomes a governess at Thornfield Hall and falls in love with the brooding Mr. Rochester, but secrets threaten their happiness."),
    Book(title: "The Chronicles of Narnia: The Lion, the Witch and the Wardrobe", imageName: "narnia", rating: 4.6, description: "Four children enter a magical world through a wardrobe.", story: "During World War II, four siblings discover the land of Narnia where they must help the lion Aslan defeat the White Witch."),
    Book(title: "Fahrenheit 451", imageName: "fahrenheit-451", rating: 4.5, description: "A fireman's journey in a world that burns books.", story: "Guy Montag, a fireman who burns books, begins to question his society and joins a group of rebels who memorize books to preserve literature."),
    Book(title: "The Grapes of Wrath", imageName: "grapes-of-wrath", rating: 4.4, description: "A family's struggle during the Great Depression.", story: "The Joad family travels from Oklahoma to California during the Dust Bowl, facing poverty and exploitation while searching for a better life.")
]
}

struct SelectedView: View {
    var book: Book
    var body: some View {
        ZStack {
            GeometryReader { geo in
                Image(book.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
            }

            Vstack {
                
            }
        }
        .ignoresSafeArea()
    }
}

struct HomeView: View {
    @State private var selectedTab: Tab = .all

    var body: some View {
        NavigationStack {
            ScrollView {
                Vstack {
                    //add horizontal scroll here of mostread books
                    segementedControl(selectedTab: $selectedTab)
                    BookView(selectedTab: $selectedTab)
                }
            }
        }
    }

}
        