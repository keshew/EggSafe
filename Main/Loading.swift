
import SwiftUI

struct URLModel: Identifiable, Equatable {
    let id = UUID()
    let urlString: String
}

struct LoadingView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var hasCheckedAuthorization = false
    @State  var url: URLModel? = nil
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State var conversionDataReceived: Bool = false
    @State var isNotif = false
    let lastDeniedKey = "lastNotificationDeniedDate"
    let configExpiresKey = "config_expires"
    let configUrlKey = "config_url"
    let configNoMoreRequestsKey = "config_no_more_requests"
    @State var isMain = false
    @State  var isRequestingConfig = false
    @StateObject  var networkMonitor = NetworkMonitor.shared
    @State var isInet = false
    @State private var hasHandledConversion = false
    
    var isPortrait: Bool {
        verticalSizeClass == .regular && horizontalSizeClass == .compact
    }
    
    var isLandscape: Bool {
        verticalSizeClass == .compact && horizontalSizeClass == .regular
    }
    @State var urlFromNotification: String? = nil
    
    var body: some View {
        VStack {
            if isPortrait {
                ZStack {
                    Image("BGforNotifications")
                        .resizable()
                        .ignoresSafeArea()
//                        .aspectRatio(contentMode: .fill)
                    
                    VStack(spacing: 50) {
                        Spacer()
                        
                        VStack(spacing: 30) {
                            Spacer()
                            
                            Text("LOADING...")
                                .font(.custom("WendyOne-Regular", size: 24))
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 40)
                            
                            ProgressView()
                        }
                    }
                    .padding(.vertical, 20)
                }
            } else {
                ZStack {
                    Image("BGforNotificationsLandscape")
                        .resizable()
                        .ignoresSafeArea()
//                        .aspectRatio(contentMode: .fill)
                    
                    VStack(spacing: 30) {
                        Spacer()
                        
                        Text("LOADING...")
                            .font(.custom("WendyOne-Regular", size: 24))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 40)
                        
                        ProgressView()
                    }
                    .padding(.bottom, 10)
                }
            }
        }
        .onReceive(networkMonitor.$isDisconnected) { disconnected in
            if disconnected {
                isInet = true
            } else {
            }
        }
        .fullScreenCover(item: $url) { item in
            Egg(urlString: item.urlString)
                .ignoresSafeArea(.keyboard)
                .onReceive(NotificationCenter.default.publisher(for: .openUrlFromNotification)) { notification in
                    if let userInfo = notification.userInfo,
                       let url = userInfo["url"] as? String {
                        urlFromNotification = url
                    }
                }
                .fullScreenCover(isPresented: Binding<Bool>(
                    get: { urlFromNotification != nil },
                    set: { newValue in if !newValue { urlFromNotification = nil } }
                )) {
                    if let urlToOpen = urlFromNotification {
                        Egg(urlString: urlToOpen)
                    } else {
                    }
                }
        }
        .onReceive(NotificationCenter.default.publisher(for: .openUrlFromNotification)) { notification in
            if let userInfo = notification.userInfo,
               let url = userInfo["url"] as? String {
                urlFromNotification = url
            }
        }
        .fullScreenCover(isPresented: Binding<Bool>(
            get: { urlFromNotification != nil },
            set: { newValue in if !newValue { urlFromNotification = nil } }
        )) {
            if let urlToOpen = urlFromNotification {
                Egg(urlString: urlToOpen)
            } else {
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .datraRecieved)) { notification in
            DispatchQueue.main.async {
                guard !isInet else { return }
                if !hasHandledConversion {
                    let isOrganic = UserDefaults.standard.bool(forKey: "is_organic_conversion")
                    if isOrganic {
                        isMain = true
                    } else {
                        checknotif()
                    }
                    hasHandledConversion = true
                } else {
                    print("Conversion event ignored due to recent handling")
                }
            }
        }
        
        .onReceive(NotificationCenter.default.publisher(for: .notificationPermissionResult)) { notification in
            req()
        }
        .fullScreenCover(isPresented: $isNotif) {
            NotificationView()
        }
        .fullScreenCover(isPresented: $isMain) {
            TabsView()
        }
        .fullScreenCover(isPresented: $isInet) {
            NoInternet()
        }
    }
}

#Preview {
    LoadingView()
}


import Network
import Combine

final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    
    @Published private(set) var isDisconnected: Bool = false
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isDisconnected = (path.status != .satisfied)
            }
        }
        monitor.start(queue: queue)
    }
}

import SwiftUI

extension View {
    func outlineText(color: Color, width: CGFloat) -> some View {
        modifier(StrokeModifier(strokeSize: width, strokeColor: color))
    }
}

struct StrokeModifier: ViewModifier {
    private let id = UUID()
    var strokeSize: CGFloat = 1
    var strokeColor: Color = .blue
    
    func body(content: Content) -> some View {
        content
            .padding(strokeSize*2)
            .background (Rectangle()
                .foregroundStyle(strokeColor)
                .mask({
                    outline(context: content)
                })
            )}
    
    func outline(context:Content) -> some View {
        Canvas { context, size in
            context.addFilter(.alphaThreshold(min: 0.01))
            context.drawLayer { layer in
                if let text = context.resolveSymbol(id: id) {
                    layer.draw(text, at: .init(x: size.width/2, y: size.height/2))
                }
            }
        } symbols: {
            context.tag(id)
                .blur(radius: strokeSize)
        }
    }
}


