import SwiftUI
import FirebaseCore
import AdSupport
import AppsFlyerLib
import AppTrackingTransparency
import SwiftUI
import FirebaseMessaging

@main
struct EggSafeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            LoadingView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, AppsFlyerLibDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    private var didRequestConversionDataAgain = false
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        let userInfo = response.notification.request.content.userInfo

        var urlString: String?

        if let url = userInfo["url"] as? String {
            urlString = url
        } else if let data = userInfo["data"] as? [String: Any],
                  let url = data["url"] as? String {
            urlString = url
        }

        if let urlString = urlString, !urlString.isEmpty {
            print("URL STRING: \(urlString)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                NotificationCenter.default.post(name: .openUrlFromNotification,
                                                object: nil,
                                                userInfo: ["url": urlString])
            }
        } else {
            print("URL not found or empty")
        }

        completionHandler()
    }
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
        UIApplication.shared.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        AppsFlyerLib.shared().appleAppID = "6753989015"
        AppsFlyerLib.shared().appsFlyerDevKey = "MtzqiJib5dDeG78shfdvTC"
        AppsFlyerLib.shared().delegate = self
        AppsFlyerLib.shared().isDebug = false
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
        NotificationCenter.default.addObserver(self, selector: #selector(dnsajkdnasda),
                                               name: UIApplication.didBecomeActiveNotification, object: nil)
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("did register 8989")
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken)) 8989")
        
        if let fcmToken {
            UserDefaults.standard.set(fcmToken, forKey: "fcmToken")
        } else {
            UserDefaults.standard.set("null", forKey: "fcmToken")
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }
    
    private func idfaSave() {
        let userIdfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        UserDefaults.standard.set(userIdfa, forKey: "idfa_of_user")
    }
    
    @objc private func dnsajkdnasda() {
        AppsFlyerLib.shared().start()
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                self.idfaSave()
            }
        } else {
            self.idfaSave()
        }
    }
    
    func onConversionDataFail(_ error: Error) {

    }
    
    func onConversionDataSuccess(_ conversionData: [AnyHashable: Any]) {
        let afUID = AppsFlyerLib.shared().getAppsFlyerUID()
        print("[AppsFlyer] conversionData, conversionData: \(conversionData)")
        UserDefaults.standard.set(afUID, forKey: "apps_flyer_id")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: conversionData, options: [])
            UserDefaults.standard.set(jsonData, forKey: "conversion_data")
        } catch {
            print("Failed to serialize conversionData: \(error)")
        }
        
        if let status = conversionData["af_status"] as? String {
            let isOrganic = (status == "Organic")
            UserDefaults.standard.set(isOrganic, forKey: "is_organic_conversion")
        } else {
            UserDefaults.standard.set(false, forKey: "is_organic_conversion")
        }
        
        NotificationCenter.default.post(name: .datraRecieved, object: nil, userInfo: conversionData)
        
        if let status = conversionData["af_status"] as? String, status == "Organic" {
            if !didRequestConversionDataAgain {
                didRequestConversionDataAgain = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    AppsFlyerLib.shared().start()
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: conversionData, options: [])
                        UserDefaults.standard.set(jsonData, forKey: "conversion_data")
                    } catch {
                        print("Failed to serialize conversionData: \(error)")
                    }
                }
            } else {
                print("We have organic conversion")
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .datraRecieved, object: nil)
    }
}

extension Notification.Name {
    static let datraRecieved = Notification.Name("datraRecieved")
    static let notificationPermissionResult = Notification.Name("notificationPermissionResult")
    static let openUrlFromNotification = Notification.Name("openUrlFromNotification")
}
