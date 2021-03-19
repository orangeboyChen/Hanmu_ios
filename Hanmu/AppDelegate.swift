//
//  AppDelegate.swift
//  Hanmu
//
//  Created by orangeboy on 2021/3/18.
//

import Foundation
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate, XGPushDelegate, UNUserNotificationCenterDelegate {
    
    /**
     https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=wx668004190386482e&secret=28665697e6d04ac8c78332cfecbc91f5
     */
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        
        UIApplication.shared.registerForRemoteNotifications()
        
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
        
    }
    
    
}
