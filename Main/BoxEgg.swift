
import SwiftUI

struct BoxEggView: View {
    let creamColor = Color(uiColor: UIColor(red: 1.0, green: 0.976, blue: 0.902, alpha: 1.0))
    
    let categories = ["Chicken", "Duck", "Quail", "Turkey", "Goose", "Ostrich", "Pigeon", "Exotic"]
    
    let eggData: [String: EggType] = [
        "Chicken": EggType(name: "Chicken", storage: "In fridge: 4-5 weeks\nRoom temp: 1-2 weeks\nFreezing: up to 1 year", temp: "0-5°C", features: "Standard, versatile.", risks: "Risk of salmonella, cook thoroughly.", imageName: "eggderevna"),
        "Duck": EggType(name: "Duck", storage: "In fridge: 2-3 weeks\nRoom temp: 1 week\nFreezing: up to 6 months", temp: "2-4°C", features: "Spoil faster due to porous shell.", risks: "High bacterial risk, always cook.", imageName: "utkiegg"),
        "Quail": EggType(name: "Quail", storage: "In fridge: 4-6 weeks\nRoom temp: 2-3 weeks\nFreezing: up to 1 year", temp: "0-5°C", features: "Last longer than chicken, small and sturdy.", risks: "Low salmonella risk, but check freshness.", imageName: "perepegg"),
        "Turkey": EggType(name: "Turkey", storage: "In fridge: 3-5 weeks\nRoom temp: 1-2 weeks\nFreezing: up to 1 year (without shell)", temp: "0-5°C", features: "Large, similar to chicken but richer in flavor.", risks: "Risk of salmonella, cook thoroughly.", imageName: "induegg"),
        "Goose": EggType(name: "Goose", storage: "In fridge: 3-4 weeks\nRoom temp: 1 week\nFreezing: up to 6 months", temp: "2-5°C", features: "Large, rich yolk, suitable for baking.", risks: "High bacterial risk due to size, store cool.", imageName: "gusiegg"),
        "Ostrich": EggType(name: "Ostrich", storage: "In fridge: 4-6 weeks\nRoom temp: up to 4 weeks\nFreezing: up to 1 year", temp: "7-13°C", features: "Huge (24 chicken eggs), thick shell, long storage.", risks: "Low risk, but check for cracks.", imageName: "strausegg"),
        "Pigeon": EggType(name: "Pigeon", storage: "In fridge: 2-3 weeks\nRoom temp: 1-2 weeks\nFreezing: up to 6 months", temp: "11-15°C", features: "Small, delicate, for special dishes.", risks: "Risk of infections, wash and cook thoroughly.", imageName: "golubegg"),
        "Exotic": EggType(name: "Exotic", storage: "In fridge: 4-8 weeks\nRoom temp: 2-4 weeks\nFreezing: up to 1 year", temp: "5-10°C", features: "Unique in size and flavor (emu, peacock), thick shell.", risks: "Rare, check freshness, allergy risk.", imageName: "exsoegg")
    ]
    
    @State private var selectedCategory: String = "Chicken"
    
    var body: some View {
        NavigationView {
            ZStack {
                creamColor
                    .ignoresSafeArea()
                
                VStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(categories, id: \.self) { category in
                                Button(action: {
                                    selectedCategory = category
                                }) {
                                    Text(category)
                                        .font(.system(size: 17, design: .rounded))
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedCategory == category ? Color.yellow : Color(.systemGray6))
                                        .cornerRadius(10)
                                        .foregroundColor(.black)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    if let egg = eggData[selectedCategory] {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Information about \(egg.name)")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(Color.brown)
                                
                                Image(egg.imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                                Text("Storage Duration")
                                    .font(.headline)
                                    .bold()
                                Text(egg.storage)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                
                                Text("Storage Temperature")
                                    .font(.headline)
                                    .bold()
                                Text(egg.temp)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                
                                Text("Features")
                                    .font(.headline)
                                    .bold()
                                Text(egg.features)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                
                                Text("Risks")
                                    .font(.headline)
                                    .bold()
                                    .foregroundColor(Color.brown)
                                Text(egg.risks)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationTitle("Storage")
            .navigationBarTitleDisplayMode(.large)
        }
        .environment(\.colorScheme, .light)
    }
}

struct EggType {
    let name: String
    let storage: String
    let temp: String
    let features: String
    let risks: String
    let imageName: String
}

#Preview {
    BoxEggView()
}
