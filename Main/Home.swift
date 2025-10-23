
import SwiftUI

struct HomeView: View {
    @Binding var favorites: [Bird]
    
    let todaysFacts = [
        "Bird eggs are remarkably similar to dinosaur eggs in structure.",
        "Birds living in colder climates often lay more colorful eggs to absorb more sunlight.",
        "The blue tit holds the record for the largest clutch size with up to 19 eggs.",
        "Bird eggs are porous, allowing gases like oxygen and carbon dioxide to pass through the shell.",
        "A female American robin lays about one egg per day.",
        "Cavity-nesting birds typically lay round, white eggs, while ground-nesters lay camouflaged, speckled ones.",
        "The kiwi lays eggs that are 20-25% of its body weight, the largest relative to body size."
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#FFF9E6")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Card of the day
                        CardView(title: "Today's Fact", fact: todaysFacts[randomIndex])
                        
                        // List of favorite bird types
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Favorite Bird Species")
                                .font(.headline)
                            
                            if favorites.isEmpty {
                                Text("No favorites yet.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            } else {
                                LazyVGrid(columns: [GridItem(.flexible())], spacing: 10) {
                                    ForEach(favorites) { bird in
                                        FavoriteBirdCard(bird: bird, favorites: $favorites)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    .padding()
                }
            }
            .navigationTitle("Home")
        }
        .environment(\.colorScheme, .light)
    }
    
    private var randomIndex: Int {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: Date())
        return (day - 1) % todaysFacts.count
    }
}

struct FavoriteBirdCard: View {
    let bird: Bird
    @Binding var favorites: [Bird]
    @State private var isFavorite = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(bird.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 100)
                .frame(maxWidth: .infinity)
            
            Text(bird.name)
                .font(.headline)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Egg size: \(bird.eggSize)")
                .font(.subheadline)
            
            Text("Color: \(bird.eggColor)")
                .font(.subheadline)
            
            Text("Facts: \(bird.facts)")
                .font(.subheadline)
                .lineLimit(2)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 3)
        .onAppear {
            isFavorite = favorites.contains(bird)
        }
    }
}

struct CardView: View {
    let title: String
    let fact: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.title2)
                .bold()
            Text(fact)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(hex: "#FFD93D").opacity(0.3))
        .cornerRadius(10)
    }
}

// Extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    HomeView(favorites: .constant([
        Bird(name: "Chicken", eggSize: "Medium", eggColor: "White/Brown", nutrition: "Protein: 6g, Fats: 5g", culinary: "In all dishes.", facts: "The most common.", imageName: "kuri")
    ]))
}
