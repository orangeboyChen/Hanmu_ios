//
//  Spider.swift
//  Hanmu
//
//  Created by orangeboy on 2021/3/11.
//

import Foundation
import Alamofire
import SwiftUI
import SwiftyJSON

protocol HanmuSpiderDelegate{
    mutating func loginDelegate(response: DataResponse<Any, AFError>)
    mutating func getUserInfoDelegate(response: DataResponse<Any, AFError>)
    mutating func getRunIdDelegate(response: DataResponse<Any, AFError>)
    mutating func postDataDelegate(response: DataResponse<Any, AFError>, speed: Double, distance: Double, costTime: Int)
}

protocol HanmuLoginDelegate {
    mutating func onSuccess()
    mutating func onError(message: String)
}

protocol HanmuRunDelegate {
    mutating func onError(message: String)
    mutating func onSuccess(speed: Double, distance: Double, costTime: Int)
}

protocol HanmuUserInfoDelegate {
    mutating func getValidResultDelegate(response: DataResponse<Any, AFError>)
    mutating func getInvalidResultDelegate(response: DataResponse<Any, AFError>)
}

class HanmuSpider {
    static let instance = HanmuSpider()
    
    //委托
    var spiderDelegate: HanmuSpiderDelegate?
    var userInfoDelegate: HanmuUserInfoDelegate?
    var runDelegate: HanmuRunDelegate?
    var loginDelegate: HanmuLoginDelegate?

    let ENCRYPT_KEY = "xfvdmyirsg";
    
    let BASE_URL_4 = "https://client4.aipao.me/api"
    let BASE_URL_3 = "http://client3.aipao.me/api"
    
    //登录用client4，其它用clinet3
    let LOGIN_URI = "/token/QM_Users/LoginSchool?IMEICode="
    
    var token: String = ""
    var userId: String = ""
    @AppStorage("imeiCode", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var imeiCode: String = ""
    
    var user: User = User()
    


    let manager: ServerTrustManager
    let session: Session

    private init(){
        self.manager = ServerTrustManager(evaluators: ["client4.aipao.me": DisabledTrustEvaluator()])
        self.session = Session(serverTrustManager: self.manager)
    }
    
    static func getInstance() -> HanmuSpider {
        return instance
    }
    
    public func run(){
        run(speed: -1)
    }
    
    public func run(speed: Double){
        if imeiCode == "" {
            runDelegate?.onError(message: "设备序列号未填写")
        }
        else if token == "" {
            let url = URL(string: "\(BASE_URL_4)\(LOGIN_URI)\(imeiCode)")!
            session.request(url, method: .get).responseJSON {response in
                let json = JSON(response.data as Any)
                if(json["Success"] == true){
                    self.token = json["Data"]["Token"].stringValue
                    self.run(speed: speed)
                }
                else {
                    self.runDelegate?.onError(message: "登录失败")
                }
                
            }
        }
        else if user.minSpeed == 0 || self.user.maxSpeed == 0 || self.user.distance == 0 {
            //获取用户信息
            let url = URL(string: "\(BASE_URL_3)/\(token)/QM_Users/GS")!
            session.request(url, method: .get).responseJSON {response in
                let json = JSON(response.data as Any)
                if(json["Success"] == true){
                    self.user.minSpeed = json["Data"]["SchoolRun"]["MinSpeed"].doubleValue
                    self.user.maxSpeed = json["Data"]["SchoolRun"]["MaxSpeed"].doubleValue
                    self.user.distance = Int32(json["Data"]["SchoolRun"]["Lengths"].intValue)
                    
                    if speed > self.user.maxSpeed {
                        self.runDelegate?.onError(message: "设置的速度过快，超过了为\(self.user.maxSpeed)m/s的上限")
                        self.user = User()
                    }
                    else if speed < self.user.minSpeed && speed != -1 {
                        self.runDelegate?.onError(message: "设置的速度过慢，超过了为\(self.user.minSpeed)m/s的下限")
                        self.user = User()
                    }
                    else {
                        self.run(speed: speed)
                    }
                    
                }
                else{
                    self.runDelegate?.onError(message: "获取用户信息失败")
                }
            }
        }
        else if user.runId == "" {
            let url = URL(string: "\(BASE_URL_3)/\(token)/QM_Runs/SRS?S1=40.62828&S2=120.79108&S3=\(String(user.distance))")!
            session.request(url, method: .get).responseJSON {response in
                let json = JSON(response.data as Any)
                if(json["Success"] == true){
                    self.user.runId = json["Data"]["RunId"].string!
                    self.run(speed: speed)
                }
                else{
                    self.runDelegate?.onError(message: "获取RunId失败")
                }
            }
        }
        else {
            print(user)
            let lowerBound: Int = Int(user.minSpeed * 100 - 50)
            let upperBound: Int = Int(user.maxSpeed * 100 + 30)
            
            let postSpeed: Double = speed == -1 ? (Double(arc4random_uniform(UInt32(upperBound - lowerBound))) + Double(lowerBound)) / 100 : speed
            let postDistance: Double = Double(user.distance) + Double(arc4random_uniform(5))
            let postCostTime: Int = Int(postDistance / postSpeed)
            let postStep: Int = Int(arc4random_uniform(2222 - 1555) + 1555)
            
            
            let url = URL(string: "\(BASE_URL_3)/\(token)/QM_Runs/ES?S1=\(user.runId)&S4=\(encryptNumber(number: postCostTime))&S5=\(encryptNumber(number: Int(postDistance)))&S6=A0A2A1A3A0&S7=1&S8=xfvdmyirsg&S9=\(encryptNumber(number: postStep))")
            
            session.request(url!, method: .get).responseJSON {response in
                let json = JSON(response.data as Any)
                if(json["Success"] == true){
                    self.runDelegate?.onSuccess(speed: postSpeed, distance: postDistance, costTime: postCostTime)

                    //初始化用户数据
                    self.user = User()
                }
                else{
                    self.runDelegate?.onError(message: "提交跑步数据失败")
                }
            }
        }
    }
    
    public func login(imeiCode : String) {
        let url = URL(string: "\(BASE_URL_4)\(LOGIN_URI)\(imeiCode)")!
        session.request(url, method: .get).responseJSON {response in
            let json = JSON(response.data as Any)
            print(json)
            if(json["Success"] == true){
                self.token = json["Data"]["Token"].string!
                self.loginDelegate?.onSuccess()
            }
            else {
                self.loginDelegate?.onError(message: json["ErrMsg"].stringValue)
            }
            
            self.spiderDelegate?.loginDelegate(response: response)
        }
    }
    
    func getUserInfo(token : String){
        let url = URL(string: "\(BASE_URL_3)/\(token)/QM_Users/GS")!
        session.request(url, method: .get).responseJSON {response in
            
            self.spiderDelegate?.getUserInfoDelegate(response: response)
        }
    }
    
    func getRunId(token : String, distance : Int32){
        let url = URL(string: "\(BASE_URL_3)/\(token)/QM_Runs/SRS?S1=40.62828&S2=120.79108&S3=\(String(distance))")!
        session.request(url, method: .get).responseJSON {response in
            self.spiderDelegate?.getRunIdDelegate(response: response)
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
        let lowerBound: Int = Int(user.minSpeed * 100 + 50)
        let upperBound: Int = Int(user.maxSpeed * 100 - 50)
        
        let postSpeed: Double = (Double(arc4random_uniform(UInt32(upperBound - lowerBound))) + Double(lowerBound)) / 100
        let postDistance: Double = Double(user.distance) + Double(arc4random_uniform(5))
        let postCostTime: Int = Int(postDistance / postSpeed)
        let postStep: Int = Int(arc4random_uniform(2222 - 1555) + 1555)
        
        
        let url = URL(string: "\(BASE_URL_3)/\(user.token)/QM_Runs/ES?S1=\(user.runId)&S4=\(encryptNumber(number: postCostTime))&S5=\(encryptNumber(number: Int(postDistance)))&S6=A0A2A1A3A0&S7=1&S8=xfvdmyirsg&S9=\(encryptNumber(number: postStep))")
        session.request(url!, method: .get).responseJSON {response in
            print("RESPONSE: \(response)")
            self.spiderDelegate?.postDataDelegate(response: response, speed: postSpeed, distance: postDistance, costTime: postCostTime)
        }
    }
    
    func getValidResult(pageNum: Int, pageSize: Int) {
        if token == "" {
            let url = URL(string: "\(BASE_URL_3)/\(LOGIN_URI)\(imeiCode)")!
            session.request(url, method: .get).responseJSON {response in
                let json = JSON(response.data as Any)
                if(json["Success"] == true){
                    self.token = json["Data"]["Token"].stringValue
                    self.getValidResult(pageNum: pageNum, pageSize: pageSize)
                }
                else {
                    print(json)
                    self.userInfoDelegate?.getValidResultDelegate(response: response)
                }
                
            }
        }
        else if userId == "" {
            let url = URL(string: "\(BASE_URL_3)/\(token)/QM_Users/GS")!
            session.request(url, method: .get).responseJSON {response in
                print(response)
                let json = JSON(response.data as Any)
                if(json["Success"].intValue == 1){
                    self.userId = json["Data"]["User"]["UserID"].stringValue
                    self.getValidResult(pageNum: pageNum, pageSize: pageSize)
                }
                else {
                    print(json)
                    self.userInfoDelegate?.getValidResultDelegate(response: response)
                }
                
            }
        }
        else {
            let url = URL(string: "\(BASE_URL_3)/\(token)/QM_Runs/getResultsofValidByUser?UserId=\(userId)&pageIndex=\(pageNum)&pageSize=\(pageSize)")
            session.request(url!, method: .get).responseJSON {response in
                print("RESPONSE: \(response)")
                self.userInfoDelegate?.getValidResultDelegate(response: response)
            }
        }
        
        
 
    }
    
    func getInvalidResult(pageNum: Int, pageSize: Int) {
        if token == "" {
            let url = URL(string: "\(BASE_URL_3)/\(LOGIN_URI)\(imeiCode)")!
            session.request(url, method: .get).responseJSON {response in
                let json = JSON(response.data as Any)
                if(json["Success"] == true){
                    self.token = json["Data"]["Token"].stringValue
                    self.getInvalidResult(pageNum: pageNum, pageSize: pageSize)
                }
                else {
                    print(json)
                    self.userInfoDelegate?.getInvalidResultDelegate(response: response)
                }
                
            }
        }
        else if userId == "" {
            let url = URL(string: "\(BASE_URL_3)/\(token)/QM_Users/GS")!
            session.request(url, method: .get).responseJSON {response in
                print(response)
                let json = JSON(response.data as Any)
                if(json["Success"].intValue == 1){
                    self.userId = json["Data"]["User"]["UserID"].stringValue
                    self.getInvalidResult(pageNum: pageNum, pageSize: pageSize)
                }
                else {
                    print(json)
                    self.userInfoDelegate?.getInvalidResultDelegate(response: response)
                }
            }
        }
        else {
            let url = URL(string: "\(BASE_URL_3)/\(token)/QM_Runs/getResultsofInValidByUser?UserId=\(userId)&pageIndex=\(pageNum)&pageSize=\(pageSize)")
            session.request(url!, method: .get).responseJSON {response in
                self.userInfoDelegate?.getInvalidResultDelegate(response: response)
            }
        }
    }
    
}



