
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

extension LoadingView {
    func checkNotificationAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                if canAskAgain() {
                    isNotif = true
                } else {
                    sendConfigRequest()
                }
            case .denied:
                sendConfigRequest()
            case .authorized, .provisional, .ephemeral:
                sendConfigRequest()
            @unknown default:
                sendConfigRequest()
            }
        }
    }
    
    func canAskAgain() -> Bool {
        if let lastDenied = UserDefaults.standard.object(forKey: lastDeniedKey) as? Date {
            let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
            return lastDenied < threeDaysAgo
        }
        return true
    }
    
    func sendConfigRequest() {
        let configNoMoreRequestsKey = "config_no_more_requests"
        if UserDefaults.standard.bool(forKey: configNoMoreRequestsKey) {
            print("Config requests are disabled by flag, exiting sendConfigRequest")
            DispatchQueue.main.async {
                finishLoadingWithoutWebview()
            }
            return
        }

        guard let conversionDataJson = UserDefaults.standard.data(forKey: "conversion_data") else {
            print("Conversion data not found in UserDefaults")
            DispatchQueue.main.async {
                UserDefaults.standard.set(true, forKey: configNoMoreRequestsKey)
                finishLoadingWithoutWebview()
            }
            return
        }

        guard var conversionData = (try? JSONSerialization.jsonObject(with: conversionDataJson, options: [])) as? [String: Any] else {
            print("Failed to deserialize conversion data")
            DispatchQueue.main.async {
                UserDefaults.standard.set(true, forKey: configNoMoreRequestsKey)
                finishLoadingWithoutWebview()
            }
            return
        }

        conversionData["push_token"] = UserDefaults.standard.string(forKey: "fcmToken") ?? ""
        conversionData["af_id"] = UserDefaults.standard.string(forKey: "apps_flyer_id") ?? ""
        conversionData["bundle_id"] = "com.eegs.encyclopediaapp.EggSafeEncyclopedia"
        conversionData["os"] = "iOS"
        conversionData["store_id"] = "6753989015"
        conversionData["locale"] = Locale.current.identifier
        conversionData["firebase_project_id"] = "255190814443"

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: conversionData, options: [])
                    let url = URL(string: "https://eggsafeencycllopedia.com/config.php")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Request error: \(error)")
                    DispatchQueue.main.async {
                        UserDefaults.standard.set(true, forKey: configNoMoreRequestsKey)
                        finishLoadingWithoutWebview()
                    }
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response")
                    DispatchQueue.main.async {
                        UserDefaults.standard.set(true, forKey: configNoMoreRequestsKey)
                        finishLoadingWithoutWebview()
                    }
                    return
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    print("Server returned status code \(httpResponse.statusCode)")
                    DispatchQueue.main.async {
                        UserDefaults.standard.set(true, forKey: configNoMoreRequestsKey)
                        finishLoadingWithoutWebview()
                    }
                    return
                }

                if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            print("Config response JSON: \(json)")
                            DispatchQueue.main.async {
                                handleConfigResponse(json)
                            }
                        }
                    } catch {
                        print("Failed to parse response JSON: \(error)")
                        DispatchQueue.main.async {
                            UserDefaults.standard.set(true, forKey: configNoMoreRequestsKey)
                            finishLoadingWithoutWebview()
                        }
                    }
                }
            }

            task.resume()
        } catch {
            print("Failed to serialize request body: \(error)")
            DispatchQueue.main.async {
                UserDefaults.standard.set(true, forKey: configNoMoreRequestsKey)
                finishLoadingWithoutWebview()
            }
        }
    }

    func handleConfigResponse(_ jsonResponse: [String: Any]) {
        if let ok = jsonResponse["ok"] as? Bool, ok,
           let url = jsonResponse["url"] as? String,
           let expires = jsonResponse["expires"] as? TimeInterval {
            UserDefaults.standard.set(url, forKey: configUrlKey)
            UserDefaults.standard.set(expires, forKey: configExpiresKey)
            UserDefaults.standard.removeObject(forKey: configNoMoreRequestsKey)
            UserDefaults.standard.synchronize()
            
            guard urlFromNotification == nil else {
                return
            }
            self.url = URLModel(urlString: url)
            print("Config saved: url = \(url), expires = \(expires)")
            
        } else {
            UserDefaults.standard.set(true, forKey: configNoMoreRequestsKey)
            UserDefaults.standard.synchronize()
            print("No valid config or error received, further requests disabled")
            finishLoadingWithoutWebview()
        }
    }
    
    func finishLoadingWithoutWebview() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isMain = true
        }
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
