//
//  IntentHandler.swift
//  SIriIntent
//
//  Created by orangeboy on 2021/3/18.
//

import Intents
import SwiftUI


class IntentHandler: INExtension, INStartWorkoutIntentHandling, HanmuRunDelegate, RunIntentHandling {

    let spider: HanmuSpider = HanmuSpider.getInstance()
    
    
    @AppStorage("imeiCode", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var imeiCode: String = ""
    @AppStorage("lastDate", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var lastDate: String = "无"
    @AppStorage("lastSpeed", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var lastSpeed: String = "无"
    @AppStorage("lastCostTime", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var lastCostTime: String = "无"
    
    let group = DispatchGroup()
    let dispatchQueue = DispatchQueue.global()
    
    var isSuccess: Bool = false
    var errorMessage: String = ""
    
    
    func onError(message: String) {
        group.leave()
        isSuccess = false
        errorMessage = message
        print(message)
        
    }
    
    func onSuccess(speed: Double, distance: Double, costTime: Int) {
        group.leave()
        isSuccess = true
        
        let dformatter = DateFormatter()
        dformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.lastDate = dformatter.string(from: Date())
        self.lastSpeed = String(speed)
        
        func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int) {
            return ((seconds) / 60, (seconds % 3600) % 60)
        }
        self.lastCostTime = String(secondsToHoursMinutesSeconds(seconds: costTime).0) + "' " + String(secondsToHoursMinutesSeconds(seconds: costTime).1) + "''"
    }
    

    
    func handle(intent: INStartWorkoutIntent, completion: @escaping (INStartWorkoutIntentResponse) -> Void) {
        if imeiCode == "" {
            completion(INStartWorkoutIntentResponse(code: .failureRequiringAppLaunch, userActivity: nil))
            return
        }
        else if intent.workoutName?.spokenPhrase != "跑步" {
            completion(INStartWorkoutIntentResponse(code: .failureNoMatchingWorkout, userActivity: nil))
            return
        }
        
        spider.runDelegate = self

        group.enter()
        dispatchQueue.async {
            self.spider.run()
        }
        
        group.notify(queue: dispatchQueue) {
            if self.isSuccess {
                completion(INStartWorkoutIntentResponse(code: .success, userActivity: nil))
            }
            else {
                completion(INStartWorkoutIntentResponse(code: .failure, userActivity: nil))
            }
        }
        
    }
    

    func handle(intent: RunIntent, completion: @escaping (RunIntentResponse) -> Void) {
        if imeiCode == "" {
            completion(RunIntentResponse.failure(failMessage: "您还没有输入有效的设备序列号哦"))
            return
        }
        
        spider.runDelegate = self
        
        group.enter()
        dispatchQueue.async {
            self.spider.run()
        }
        
        group.notify(queue: dispatchQueue) {
            if self.isSuccess {
                completion(RunIntentResponse(code: .success, userActivity: nil))
            }
            else {
                completion(RunIntentResponse.failure(failMessage: self.errorMessage))
            }
        }
    }

    
    
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
}

class MyResponse: INStartWorkoutIntentResponse {
    
}
