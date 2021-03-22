//
//  HanmuApp.swift
//  Hanmu
//
//  Created by orangeboy on 2021/3/11.
//

import SwiftUI
import Intents
import WidgetKit

@main
struct HanmuApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @Environment(\.scenePhase) private var scenePhase
    
    @AppStorage("imeiCode") var desperateImeiCode: String = ""
    
    @AppStorage("imeiCode", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.xiaoqing")) var savedImeiCode: String = ""
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear(perform: {
                    WidgetCenter.shared.reloadTimelines(ofKind: "LibraryWidget")
                    if desperateImeiCode != "" {
                        savedImeiCode = desperateImeiCode
                        desperateImeiCode = ""
                    }
                })
        }.onChange(of: scenePhase){parse in
            INPreferences.requestSiriAuthorization(){_ in }
        }
    }
    
}
