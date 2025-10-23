
import SwiftUI

struct TestEggView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#FFF9E6")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        TestSection(title: "Floating Egg", description: "Drop the egg in water: fresh sinks, old floats.")
                        TestSection(title: "Smell and Sound Test", description: "Shake it: if you hear a sound, the egg is old. The smell should be neutral.")
                        TestSection(title: "Expiration Date Check", description: "Check the marking on the shell.")
                        
                        TipSection(title: "Storage for Incubation", tip: "Store at 10-15°C, humidity 75-80%.")
                        TipSection(title: "Freezing", tip: "Separate white and yolk, freeze separately.")
                        TipSection(title: "Washing Eggs", tip: "Do not wash chicken eggs before storage to preserve the protective layer.")
                    }
                    .padding()
                }
            }
            .navigationTitle("Tips and Tests")
        }
        .environment(\.colorScheme, .light)
    }
}

struct TestSection: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.leading)
            Text(description)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(hex: "#4ACFAC").opacity(0.2))
        .cornerRadius(10)
    }
}

struct TipSection: View {
    let title: String
    let tip: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.leading)
            Text(tip)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(hex: "#FFD93D").opacity(0.2))
        .cornerRadius(10)
    }
}

#Preview {
    TestEggView()
}
