//
//  HanmuApp.swift
//  WatchApp Extension
//
//  Created by orangeboy on 2021/6/22.
//

import SwiftUI

@main
struct HanmuApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
