
import SwiftUI

struct TabsView: View {
    @State private var favorites: [Bird] = []
    
    var body: some View {
        TabView {
            HomeView(favorites: $favorites)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .onAppear {
                    // Ensure state is preserved; already handled at root level
                }
            
            BoxEggView()
                .tabItem {
                    Label("Storage", systemImage: "archivebox")
                }
                .onAppear {
                    // Add any load logic here if BoxEggView has persistent state
                }
            
            LearnEggView(favorites: $favorites)
                .tabItem {
                    Label("Encyc.", systemImage: "book")
                }
                .onAppear {
                    // Favorites already bound and persisted
                }
            
            TestEggView()
                .tabItem {
                    Label("Tips", systemImage: "lightbulb")
                }
                .onAppear {
                    // Add any load logic here if TestEggView has persistent state
                }
            
            FavouriteView(favorites: $favorites)
                .tabItem {
                    Label("Favorites", systemImage: "star")
                }
                .onAppear {
                    // Notes loaded in FavouriteView onAppear; favorites bound
                }
        }
        .accentColor(Color(hex: "#FFD93D"))
        .font(.system(.body, design: .rounded)) // Friendly font style
        .onAppear {
            loadFavorites()
        }
        .onChange(of: favorites) { _ in
            saveFavorites()
        }
    }
    
    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(data, forKey: "favorites")
        }
    }
    
    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: "favorites"),
           let decoded = try? JSONDecoder().decode([Bird].self, from: data) {
            favorites = decoded
        }
    }
}

// Use the same Color extension

#Preview {
    TabsView()
}
