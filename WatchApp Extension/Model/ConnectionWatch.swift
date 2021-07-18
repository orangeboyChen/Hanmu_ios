//
//  Connection.swift
//  WatchApp Extension
//
//  Created by orangeboy on 2021/6/23.
//

import Foundation
import WatchConnectivity
import SwiftUI

protocol ConnectionDelegate {
    mutating func didReceiveLibraryToken()
}

class ConnectionWatch: NSObject, WCSessionDelegate, ObservableObject {

    
    @AppStorage("libraryToken", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var token: String = ""
    @AppStorage("password", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var password: String = ""
    @AppStorage("userId", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var userId: String = ""
    
    var connectionDelegate: ConnectionDelegate?
    
    
    var session: WCSession
    
    private static var instance = ConnectionWatch()
    
    public static func getInstance() -> ConnectionWatch {
        return .instance
    }
    
    init(session: WCSession = .default){
        
        self.session = session
        super.init()
        session.delegate = self
        self.session.delegate = self
        session.activate()

    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
//        DispatchQueue.main.async{
            print("===")
            self.token = message["libraryToken"] as! String
            print(self.token)
//        }
        self.token = message["libraryToken"] as! String
        
        if token != "" {
            connectionDelegate?.didReceiveLibraryToken()
        }
    }
    
    

    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
//        DispatchQueue.main.async{
//
//        }
        self.token = message["libraryToken"] as! String
        
        if token != "" {
            connectionDelegate?.didReceiveLibraryToken()
        }



    }
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print(error?.localizedDescription)
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        
    }
    
#if os(iOS)
    
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    #endif
    
    
    
}


