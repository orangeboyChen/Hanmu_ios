//
//  HanmuApp.swift
//  Hanmu
//
//  Created by orangeboy on 2021/3/11.
//

import SwiftUI



class AppDelegate: NSObject, UIApplicationDelegate, XGPushDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        
        XGPush.defaultManager().configureClusterDomainName("tpns.tencent.com")
        XGPush.defaultManager().startXG(withAccessID: 1600017845, accessKey: "I6132G9TK5U1", delegate: self)
        XGPush.defaultManager().isEnableDebug = true
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    }
    
    
    func xgPushDidReceiveRemoteNotification(_ notification: Any, withCompletionHandler completionHandler: ((UInt) -> Void)? = nil) {
        
    }
    
    func xgPushDidReceiveNotificationResponse(_ response: Any, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response)
    }
    
    func xgPushDidFailToRegisterDeviceTokenWithError(_ error: Error?) {
        print("CALLERROR: \(error)")
    }
    
    
}


@main
struct HanmuApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
