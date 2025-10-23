
import SwiftUI
import PhotosUI
import UIKit

struct FavouriteView: View {
    @Binding var favorites: [Bird]
    @State private var notes: [String] = []
    
    @State private var showAddBirdSheet = false
    @State private var showAddNoteSheet = false
    
    @State private var newBirdName: String = ""
    
    @State private var newNote: String = ""
    
    // Photo picker states
    @State private var showPhotoPicker = false
    @State private var selectedImage: UIImage? = nil
    
    private var userFavorites: [Bird] {
        favorites.filter { bird in
            bird.imageName.isEmpty || bird.imageName.hasSuffix(".jpg")
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#FFF9E6")
                    .ignoresSafeArea()
                
                List {
                    HStack {
                        Button("Add bird/Egg species") {
                            showAddBirdSheet = true
                        }
                        .frame(width: 200)
                        .padding()
                        .background(Color(hex: "#4ACFAC"))
                        .cornerRadius(10)
                        .foregroundColor(Color.white)
                        
                        Spacer()
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    .listRowBackground(Color.clear)
                    
                    Color.clear
                        .frame(height: 15)
                        .listRowBackground(Color.clear)
                    
                    HStack {
                        Button("Add Note") {
                            showAddNoteSheet = true
                        }
                        .frame(width: 200)
                        .padding()
                        .background(Color(hex: "#FFD93D"))
                        .cornerRadius(10)
                        .foregroundColor(Color.white)
                        
                        Spacer()
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    .listRowBackground(Color.clear)
                    
                    Section(header: Text("Favorite Species")) {
                        ForEach(Array(userFavorites.enumerated()), id: \.offset) { index, bird in
                            HStack {
                                if let image = loadImage(for: bird.imageName) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                        .cornerRadius(8)
                                }
                                Text(bird.name)
                            }
                        }
                        .onDelete { indices in
                            for index in indices.sorted(by: >) {
                                let birdToDelete = userFavorites[index]
                                if let originalIndex = favorites.firstIndex(where: { $0.id == birdToDelete.id }) {
                                    favorites.remove(at: originalIndex)
                                }
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    
                    Section(header: Text("Personal Notes")) {
                        ForEach(notes, id: \.self) { note in
                            Text(note)
                        }
                        .onDelete { indices in
                            notes.remove(atOffsets: indices)
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                }
                .listStyle(.plain)
                .onAppear {
                    UITableView.appearance().backgroundColor = .clear
                    UITableViewCell.appearance().backgroundColor = .clear
                    loadNotes()
                }
                .onChange(of: notes) { _ in
                    saveNotes()
                }
            }
            .navigationTitle("Favorites")
            .fullScreenCover(isPresented: $showAddBirdSheet) {
                ZStack {
                    Color(hex: "#FFF9E6")
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        Text("Add Bird")
                            .font(.headline)
                        
                        TextField("Bird Name", text: $newBirdName)
                            .padding()
                            .background(Color(hex: "#F5EFD9"))
                            .cornerRadius(10)
                        
                        Button("+ Add Photo") {
                            showPhotoPicker = true
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        
                        if let selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(10)
                        }
                        
                        HStack {
                            Button("Back") {
                                showAddBirdSheet = false
                                newBirdName = ""
                                selectedImage = nil
                                showPhotoPicker = false
                            }
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .foregroundColor(.black)
                            
                            Spacer()
                            
                            Button("Save") {
                                if !newBirdName.isEmpty {
                                    // Save image if selected
                                    var imageName = ""
                                    if let image = selectedImage {
                                        // Simple way: save to documents and generate name
                                        let fileName = UUID().uuidString + ".jpg"
                                        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                                            let fileURL = documentsPath.appendingPathComponent(fileName)
                                            if let data = image.jpegData(compressionQuality: 0.8) {
                                                try? data.write(to: fileURL)
                                                imageName = fileName
                                            }
                                        }
                                    }
                                    let newBird = Bird(name: newBirdName, eggSize: "", eggColor: "", nutrition: "", culinary: "", facts: "", imageName: imageName)
                                    favorites.append(newBird)
                                    showAddBirdSheet = false
                                    newBirdName = ""
                                    selectedImage = nil
                                    showPhotoPicker = false
                                }
                            }
                            .padding()
                            .background(Color(hex: "#4ACFAC"))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                        }
                    }
                    .padding()
                }
                .sheet(isPresented: $showPhotoPicker) {
                    PhotoPicker(selectedImage: $selectedImage)
                }
            }
            .fullScreenCover(isPresented: $showAddNoteSheet) {
                ZStack {
                    Color(hex: "#FFF9E6")
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        Text("Add Note")
                            .font(.headline)
                        
                        TextField("Note", text: $newNote)
                            .padding()
                            .background(Color(hex: "#F5EFD9"))
                            .cornerRadius(10)
                        
                        HStack {
                            Button("Back") {
                                showAddNoteSheet = false
                                newNote = ""
                            }
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .foregroundColor(.black)
                            
                            Spacer()
                            
                            Button("Save") {
                                if !newNote.isEmpty {
                                    notes.append(newNote)
                                    showAddNoteSheet = false
                                    newNote = ""
                                }
                            }
                            .padding()
                            .background(Color(hex: "#FFD93D"))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                        }
                    }
                    .padding()
                }
            }
        }
        .environment(\.colorScheme, .light)
    }
    
    private func saveNotes() {
        if let data = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(data, forKey: "notes")
        }
    }
    
    private func loadNotes() {
        if let data = UserDefaults.standard.data(forKey: "notes"),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            notes = decoded
        }
    }
    
    private func loadImage(for filename: String) -> UIImage? {
        guard !filename.isEmpty,
              let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let fileURL = documentsPath.appendingPathComponent(filename)
        return UIImage(contentsOfFile: fileURL.path)
    }
}

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        if let uiImage = image as? UIImage {
                            self.parent.selectedImage = uiImage
                        }
                    }
                }
            }
        }
    }
}

// Use the same Color extension

#Preview {
    FavouriteView(favorites: .constant([]))
}
