//
//  Spider.swift
//  Hanmu
//
//  Created by orangeboy on 2021/3/11.
//

import Foundation
import Alamofire

protocol HanmuSpiderDelegate{
    mutating func loginDelegate(response: DataResponse<Any, AFError>)
    mutating func getUserInfoDelegate(response: DataResponse<Any, AFError>)
    mutating func getRunIdDelegate(response: DataResponse<Any, AFError>)
    mutating func postDataDelegate(response: DataResponse<Any, AFError>, speed: Double, distance: Double, costTime: Int)
}

class HanmuSpider {
    static let instance = HanmuSpider()
    
    var delegate: HanmuSpiderDelegate?

    let ENCRYPT_KEY = "xfvdmyirsg";
    let LOGIN_URL = "https://client4.aipao.me/api/token/QM_Users/LoginSchool?IMEICode=";

    let INFO_URL_PREFIX = "http://client3.aipao.me/api/";
    let INFO_URL_SUFFIX = "/QM_Users/GS";

    let RUN_ID_PREFIX = "http://client3.aipao.me/api/";
    let RUN_ID_SUFFIX = "/QM_Runs/SRS?S1=40.62828&S2=120.79108&S3=";

    let manager: ServerTrustManager
    let session: Session

    private init(){
        self.manager = ServerTrustManager(evaluators: ["client4.aipao.me": DisabledTrustEvaluator()])
        self.session = Session(serverTrustManager: self.manager)
    }
    
    static func getInstance() -> HanmuSpider {
        return instance
    }
    
    public func login(imeiCode : String) {
        let url = URL(string: LOGIN_URL + imeiCode)!
        session.request(url, method: .get).responseJSON {response in
            self.delegate?.loginDelegate(response: response)
        }
    }
    
    func getUserInfo(token : String){
        let url = URL(string: INFO_URL_PREFIX + token + INFO_URL_SUFFIX)!
        session.request(url, method: .get).responseJSON {response in
            self.delegate?.getUserInfoDelegate(response: response)
        }
    }
    
    func getRunId(token : String, distance : Int32){
        let url = URL(string: RUN_ID_PREFIX + token + RUN_ID_SUFFIX + String(distance))!
        session.request(url, method: .get).responseJSON {response in
            self.delegate?.getRunIdDelegate(response: response)
        }
    }
    
    
    func encryptNumber(number : Int) -> String{
        var dict : Dictionary<Int, Character> = [:]
        
        var i = 0
        ENCRYPT_KEY.forEach { (c) in
            dict[i] = c
            i += 1
        }
        
        var result : String = ""
        let numberString = String(number)
        numberString.forEach { (c) in
            let targetIndex : Int = Int(c.asciiValue! - Character("0").asciiValue!)
            result.append(String(dict[targetIndex]!))
        }
        
        return result
    }
    
    func postFinishRunning(user : User){
        let lowerBound: Int = Int(user.minSpeed * 100 - 50)
        let upperBound: Int = Int(user.maxSpeed * 100 + 30)
        
        let postSpeed: Double = (Double(arc4random_uniform(UInt32(upperBound - lowerBound))) + Double(lowerBound)) / 100
        let postDistance: Double = Double(user.distance) + Double(arc4random_uniform(5))
        let postCostTime: Int = Int(postDistance / postSpeed)
        let postStep: Int = Int(arc4random_uniform(2222 - 1555) + 1555)
        
        let url = URL(string:
                        "http://client3.aipao.me/api/" +
                                user.token +
                                "/QM_Runs/ES?" +
                                "S1=" +
                                user.runId +
                                "&S4=" +
                        encryptNumber(number: postCostTime) +
                                "&S5=" +
                                encryptNumber(number: Int(postDistance)) +
                                "&S6=A0A2A1A3A0&S7=1&S8=xfvdmyirsg&S9=" +
                                encryptNumber(number: postStep))
        session.request(url!, method: .get).responseJSON {response in
            print("RESPONSE: \(response)")
            self.delegate?.postDataDelegate(response: response, speed: postSpeed, distance: postDistance, costTime: postCostTime)
        }
    }
    
}


struct User{
    var schoolName : String = ""
    var minSpeed : Double = 0
    var maxSpeed : Double = 0
    var imeiCode : String = ""
    var token : String = ""
    var runId : String = ""
    var costTime : Int64 = 0
    var distance : Int32 = 0
    var step : Int64 = 0
}
