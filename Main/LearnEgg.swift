
import SwiftUI

struct LearnEggView: View {
    let birdsData = [
        Bird(name: "Chicken", eggSize: "Medium", eggColor: "White/Brown", nutrition: "Protein: 6g, Fats: 5g", culinary: "In all dishes.", facts: "The most common.", imageName: "kuri"),
        Bird(name: "Duck", eggSize: "Large", eggColor: "Greenish", nutrition: "Protein: 9g, Fats: 8g", culinary: "In Asian cuisine.", facts: "More fatty.", imageName: "utinia"),
        Bird(name: "Quail", eggSize: "Small", eggColor: "White with brown spots", nutrition: "Protein: 1.2g, Fats: 1g", culinary: "In salads and snacks.", facts: "Rich in vitamins.", imageName: "perepilinie"),
        Bird(name: "Turkey", eggSize: "Large", eggColor: "Pale cream with specks", nutrition: "Protein: 11g, Fats: 9g", culinary: "In baking and frying.", facts: "More nutritious.", imageName: "indugi"),
        Bird(name: "Goose", eggSize: "Very large", eggColor: "White", nutrition: "Protein: 20g, Fats: 20g", culinary: "In omelets and baking.", facts: "Large yolk.", imageName: "anton"),
        Bird(name: "Ostrich", eggSize: "Huge (3 kg)", eggColor: "Cream", nutrition: "Protein: 235g, Fats: 150g", culinary: "In large omelets.", facts: "Equivalent to 24 chicken eggs.", imageName: "strauss"),
        Bird(name: "Pigeon", eggSize: "Small", eggColor: "White", nutrition: "Protein: 2g, Fats: 1.5g", culinary: "In gourmet cuisine.", facts: "Rare delicacy.", imageName: "golubia"),
        Bird(name: "Exotic", eggSize: "Large", eggColor: "White", nutrition: "Protein: 12g, Fats: 8g", culinary: "In exotic dishes.", facts: "High protein content.", imageName: "pavlo")
    ]
    
    @Binding var favorites: [Bird]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#FFF9E6")
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 20) {
                        ForEach(birdsData) { bird in
                            BirdCard(bird: bird, favorites: $favorites)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Encyclopedia")
        }
        .environment(\.colorScheme, .light)
    }
}

struct Bird: Identifiable, Equatable, Codable {
    let id = UUID()
    let name: String
    let eggSize: String
    let eggColor: String
    let nutrition: String
    let culinary: String
    let facts: String
    let imageName: String
    
    static func == (lhs: Bird, rhs: Bird) -> Bool {
        lhs.name == rhs.name
    }
}

struct BirdCard: View {
    let bird: Bird
    @Binding var favorites: [Bird]
    @State private var isFavorite = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(bird.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 180)
                .frame(maxWidth: .infinity)
                .cornerRadius(10)
            
            Text(bird.name)
                .font(.headline)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Egg size: \(bird.eggSize)")
                .font(.subheadline)
            
            Text("Color: \(bird.eggColor)")
                .font(.subheadline)
            
            Text("Nutritional value: \(bird.nutrition)")
                .font(.subheadline)
            
            Text("Culinary: \(bird.culinary)")
                .font(.subheadline)
            
            Text("Facts: \(bird.facts)")
                .font(.subheadline)
            
            Button(action: {
                isFavorite.toggle()
                if isFavorite {
                    if !favorites.contains(bird) {
                        favorites.append(bird)
                    }
                } else {
                    favorites.removeAll { $0 == bird }
                }
            }) {
                HStack {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .foregroundColor(isFavorite ? .white : Color(hex: "#FFD93D"))
                    Text(isFavorite ? "Remove from favorites" : "Favourite")
                        .foregroundColor(.white)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Color(hex: "#4ACFAC"))
                .cornerRadius(10)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .onAppear {
            isFavorite = favorites.contains(bird)
        }
    }
}

// Use the same Color extension

#Preview {
    LearnEggView(favorites: .constant([]))
}
