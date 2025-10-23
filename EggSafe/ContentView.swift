
import SwiftUI

// Основной вид приложения с сохранением favorites в UserDefaults
struct ContentView: View {
    @State private var favorites: [Bird] = []
    
    var body: some View {
        TabView {
            HomeView(favorites: $favorites)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            LearnEggView(favorites: $favorites)
                .tabItem {
                    Label("Encyclopedia", systemImage: "book")
                }
            
            FavouriteView(favorites: $favorites)
                .tabItem {
                    Label("Favorites", systemImage: "star")
                }
        }
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

#Preview {
    ContentView()
}
