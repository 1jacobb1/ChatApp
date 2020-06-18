//
//  AppDelegate.swift
//  Jacob Chat App
//
//  Created by FDC Jacob on 6/16/20.
//  Copyright © 2020 FDC Jacob. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseMessaging
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var isLoggedIn = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        if #available(iOS 13.0, *) {
        } else {
            // Fallback on earlier versions
            // set root view / main page
            self.window = UIWindow(frame: UIScreen.main.bounds)
            setMainPage()
        }
        
        registerForPushNotifications()
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        debugPrint("REGISTERED PUSH NOTIFICATION")
        debugPrint(token)
        
        // - firebase messaging
        Messaging.messaging().apnsToken = deviceToken
        
        // - save new firebase push notif token
        DataManager.shared.updateFirebaseToken()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            debugPrint("Message ID: \(messageID)")
        }

        // Print full message.
        debugPrint(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            debugPrint("Message ID: \(messageID)")
        }

        // Print full message.
        debugPrint(userInfo)

        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Jacob_Chat_App")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    /// MARK: - UNUserNotificationCenterDelegate
    let gcmMessageIDKey = "gcm.message_id"
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        if let messageID = userInfo[gcmMessageIDKey] {
            debugPrint("userNotificationCenter: willpresent message id \(messageID) userinfo: \(userInfo)")
        }
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let _ = userInfo[gcmMessageIDKey] {}
        if let messageID = userInfo[gcmMessageIDKey] {
            debugPrint("userNotificationCenter: didReceive message id \(messageID) userinfo: \(userInfo)")
        }
        completionHandler()
    }
    
    /// MARK: - MessagingDelegate
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        let dataDict: [String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        debugPrint("messaging: didreceivenotification fcmToken \(fcmToken)")
        // - register token
    }
    
    func redirectToSignupPage() {
        DataManager.shared.clearUserInfo()
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let main = sb.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        let vc = sb.instantiateViewController(withIdentifier: "SignUpViewController")
        main.useControllerOnLoad = vc
        goToPage(page: main)
    }
    
    func redirectChatPage() {
        setMainPage()
    }
    
    func setMainPage() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        var _window: UIWindow?
        var vc: UIViewController!
        if #available(iOS 13.0, *) {
            let sceneDelegate = UIApplication.shared.delegate as? SceneDelegate
            _window = sceneDelegate?.window
        } else {
            _window = window
        }
        
        debugPrint("set_main_page: username \(DataManager.shared.getUsernameAsId())")
        
        isLoggedIn = !DataManager.shared.getUsernameAsId().isEmpty
        
        if isLoggedIn {
            vc = sb.instantiateViewController(withIdentifier: "ChatViewController")
        } else {
            vc = sb.instantiateViewController(withIdentifier: "IndexViewController")
        }
        
        if let __window = _window {
            __window.rootViewController = vc
            __window.makeKeyAndVisible()
        }
    }
    
    func goToPage(page: UIViewController) {
        var _window: UIWindow?
        if #available(iOS 13.0, *) {
            let delegate = UIApplication.shared.delegate as? SceneDelegate
            _window = delegate?.window
        } else {
            _window = self.window
        }
        
        if let __window = _window {
            __window.rootViewController = page
            __window.makeKeyAndVisible()
        }
    }
    
    func registerForPushNotifications() {
        let application = UIApplication.shared
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self

            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
        }
    }
}
