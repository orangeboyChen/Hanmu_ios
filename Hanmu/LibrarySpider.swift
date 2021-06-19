//
//  LibrarySpider.swift
//  Hanmu
//
//  Created by orangeboy on 2021/3/13.
//

import Foundation
import Alamofire
import SwiftyJSON
import SwiftUI


protocol LibrarySpiderDelegate {
    mutating func getLibraryInfoDelegate(data: AFDataResponse<Any>)
    mutating func getRoomDetailDelegate(data: AFDataResponse<String>)
    mutating func getIsValidTokenDelegate(data: AFDataResponse<Any>)
    mutating func getSeatDetailDelegate(data: AFDataResponse<Any>)
    mutating func searchSeatDelegate(data: AFDataResponse<Any>)
    mutating func bookDelegate(data: AFDataResponse<String>, isFree: Bool)
}

protocol RebookDelegate {
    mutating func changeTimeDelegate(status: LibrarySpider.RebookStatus, data: String)
}

protocol LoginDelegate {
    mutating func loginDelegate(data: AFDataResponse<Any>)
}

protocol UserInfoDelegate {
    mutating func getUserInfoDelegate(data: AFDataResponse<Any>)
}

protocol BookControlDelegate {
    mutating func cancelDelegate(data: AFDataResponse<Any>)
    mutating func stopDelegate(data: AFDataResponse<Any>)
}

protocol HistoryDelegate {
    mutating func getHistoryDelegate(data: AFDataResponse<String>)
}

protocol HistoryPageDelegate {
    mutating func getHistoryDelegate(data: AFDataResponse<Any>)
}

class LibrarySpider {
    //固定的URL与URI
    private let BASE_URL = "https://seat.lib.whu.edu.cn:8443"
    private let LOGIN_URI = "/rest/auth"
    private let ROOM_INFO_URI = "/rest/v2/free/filters"
    private let ROOM_DETAIL_URI = "/rest/v2/room/stats2/"
    private let CHECK_VALID_TOKEN_URI = "/rest/v2/violations"
    private let SEAT_DETAIL_URI = "/rest/v2/room/layoutByDate/"
    private let SEARCH_SEAT_BY_TIME_URI = "/rest/v2/searchSeats/"
    private let BOOK_URI = "/rest/v2/freeBook"
    private let CANCEL_URI = "/rest/v2/cancel/"
    private let USER_INFO_URI = "/rest/v2/user"
    private let HISTORY_URI = "/rest/v2/history/"
    private let STOP_URI = "/rest/v2/stop"
    
    //单例模式
    private static let instance = LibrarySpider()
    private init() {}
    public static func getInstance() -> LibrarySpider{
        return instance
    }
    
    //委托
    var delegate: LibrarySpiderDelegate?
    var bookControlDelegate: BookControlDelegate?
    var historyDelegate: HistoryDelegate?
    var userInfoDelegate: UserInfoDelegate?
    var loginDelegate: LoginDelegate?
    var historyPageDelegate: HistoryPageDelegate?
    var changeTimeDelegate: RebookDelegate?
    
    //常量
    enum RebookStatus: Int {
        case success = 0
        case queryError = 1
        case cancelError = 2
        case bookError = 3
    }

    
    
    //爬取需要的信息
    @AppStorage("libraryToken", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var token: String = ""
    @AppStorage("password", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var password: String = ""
    @AppStorage("userId", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var userId: String = ""
    
    @AppStorage("lastBookSeatId", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var lastBookSeatId: Int = -1
    
    public func login(userId: String, password: String) {
        let parameters = ["username": userId, "password": password]
        AF.request(BASE_URL + LOGIN_URI, method: .get, parameters: parameters).responseJSON { (response) in
            let json = JSON(response.data)
            
            if json["status"].string == "success" {
                self.token = json["data"]["token"].string!
            }
            self.loginDelegate?.loginDelegate(data: response)
        }
    }
    
    public func login() {
        let parameters = ["username": userId, "password": password]
        AF.request(BASE_URL + LOGIN_URI, method: .get, parameters: parameters).responseJSON { (response) in
            let json = JSON(response.data)
            
            if json["status"].string == "success" {
                self.token = json["data"]["token"].string!
            }
            self.loginDelegate?.loginDelegate(data: response)
        }
    }
    
    public func getLibraryInfo() {
        let header: HTTPHeaders = ["token": token]
        AF.request(BASE_URL + ROOM_INFO_URI, method: .get, headers: header).responseJSON { (response) in
            self.delegate?.getLibraryInfoDelegate(data: response)
        }
    }
    
    public func getRoomDetail(libraryId: String){
        print(token)
        let header: HTTPHeaders = [
            "token": token
        ]
        AF.request(BASE_URL + ROOM_DETAIL_URI + libraryId, method: .get, headers: header).responseString { (response) in
            self.delegate?.getRoomDetailDelegate(data: response)
        }
    }
    
    public func getIsValidToken(){
        let header: HTTPHeaders = ["token": token]
        AF.request(BASE_URL + CHECK_VALID_TOKEN_URI, method: .get, headers: header).responseJSON { (response) in
            self.delegate?.getIsValidTokenDelegate(data: response)
        }
    }
    
    public func getSeatDetail(roomId: String, dateStr: String){
        let header: HTTPHeaders = ["token": token]
        AF.request(BASE_URL + SEAT_DETAIL_URI + roomId + "/" + dateStr, method: .get, headers: header).responseJSON { (response) in
            self.delegate?.getSeatDetailDelegate(data: response)
        }
    }
    
    public func searchSeatByTime(buildingId: String, roomId: String, dateStr: String, startTime: String, endTime: String){
        let header: HTTPHeaders = ["token": token]
        let parameters: Parameters = [
            "t": 1,
            "roomId": roomId,
            "buildingId": buildingId,
            "batch": 9999,
            "page": 1,
            "t2": 2
        ]
        
        AF.request(BASE_URL + SEARCH_SEAT_BY_TIME_URI + dateStr + "/" + startTime + "/" + endTime, method: .get, parameters: parameters, headers: header).responseJSON { (response) in
            self.delegate?.searchSeatDelegate(data: response)
        }
    }
    
    public func book(t: String, t2: String, startTime: String, endTime: String, seat: String, date: String, userId: String, password: String){
        //先登录
//        let parameters = [userId: password]
//        AF.request(BASE_URL + LOGIN_URI, method: .get, parameters: parameters).responseJSON { (response) in
//            let responseJson = JSON(response.data)
//            if responseJson["status"] == "success" {
//                self.token = responseJson["data"]["token"].string ?? self.token
//
//                //访问预定接口
//                let header: HTTPHeaders = ["token": self.token]
//                let parameters: Parameters = [
//                    "t": t,
//                    "startTime": startTime,
//                    "endTime": endTime,
//                    "seat": seat,
//                    "date": date,
//                    "t2": t2
//                ]
//
//                AF.request(self.BASE_URL + self.BOOK_URI, method: .post, parameters: parameters, headers: header).responseJSON { (response) in
//                    self.delegate?.bookDelegate(data: response)
//                }
//            }
//
//
//        }
        //访问预定接口
        URLCache.shared.removeAllCachedResponses()
        Alamofire.Session.default.sessionConfiguration.requestCachePolicy = .reloadIgnoringCacheData
        
        let header: HTTPHeaders = [
            "token": self.token,
            "Cache-Control": "no-cache",
            "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
            "User-Agent": ""
        ]
        //book== ["t": "1", "seat": "73478", "endTime": "1350", "startTime": "1170", "date": "2021-06-19", "t2": "2"]
        
        let parameters: Parameters = [
            "t": t,
            "startTime": startTime,
            "endTime": endTime,
            "seat": seat,
            "date": date,
            "t2": t2
        ]
        
        print("book== \(parameters)")
        
        AF.request(self.BASE_URL + self.BOOK_URI, method: .post, parameters: parameters, headers: header).responseString { (response) in
            self.delegate?.bookDelegate(data: response, isFree: true)
        }
    }
    
    public func cancel(id: String){
        let header: HTTPHeaders = ["token": token]
        AF.request("\(BASE_URL)\(CANCEL_URI)/\(id)", method: .get, headers: header).responseJSON { (response) in
            self.bookControlDelegate?.cancelDelegate(data: response)
        }
    }
    
    public func history(pageNum: Int, pageSize: Int){
        let header: HTTPHeaders = ["token": token]
        
        AF.request(BASE_URL + HISTORY_URI + String(pageNum) + "/" + String(pageSize), method: .get, headers: header).responseString { (response) in
            self.historyDelegate?.getHistoryDelegate(data: response)
        }
    }
    
    public func historyPage(pageNum: Int, pageSize: Int){
        let header: HTTPHeaders = ["token": token]
        print(BASE_URL + HISTORY_URI + String(pageNum) + "/" + String(pageSize))
        AF.request(BASE_URL + HISTORY_URI + String(pageNum) + "/" + String(pageSize), method: .get, headers: header).responseJSON { (response) in
            self.historyPageDelegate?.getHistoryDelegate(data: response)
        }
    }
    
    public func stop(){
        let header: HTTPHeaders = ["token": token]
        AF.request(BASE_URL + STOP_URI, method: .get, headers: header).responseJSON { (response) in
            self.bookControlDelegate?.stopDelegate(data: response)
        }
    }
    
    public func getUserInfo(){
        let header: HTTPHeaders = ["token": token]
        AF.request(BASE_URL + USER_INFO_URI, method: .get, headers: header).responseJSON { (response) in
            self.userInfoDelegate?.getUserInfoDelegate(data: response)
        }
    }
    
    public func changeBookTime(t: String, t2: String, startTime: String, endTime: String, date: String) {
        //1.获取预约内容
        let header: HTTPHeaders = ["token": self.token]
        AF.request(BASE_URL + HISTORY_URI + "1/5", method: .get, headers: header).responseString { (data) in
            //判断账号是否被系统锁了
            print("1 ==\(data)")
            if data.value == "ERROR: Abnormal using detected!!!" {
                self.token = ""
                self.changeTimeDelegate?.changeTimeDelegate(status: RebookStatus.queryError, data: "你被临时禁止登录")
                return
            }
            
            //解析数据
            let json = JSON(parseJSON: data.value ?? "")
            print(json)
            if json["status"] == "success" {
                //数据实体化，找到预约的数据
                let currentBook: Book = Book()
                json["data"]["reservations"].forEach { (str: String, subJson: JSON) in
                    let status = subJson["stat"]
                    if status == "RESERVE" || status == "CHECK_IN" || status == "AWAY" {
                        currentBook.id = subJson["id"].intValue
                        currentBook.date = subJson["date"].stringValue
                        currentBook.begin = subJson["begin"].stringValue
                        currentBook.end = subJson["end"].stringValue
                        currentBook.awayBegin = subJson["awayBegin"].stringValue
                        currentBook.awayEnd = subJson["awayEnd"].stringValue
                        currentBook.stat = subJson["stat"].stringValue
                        currentBook.loc = subJson["loc"].stringValue
                    }
                }
                
                //没有预约记录
                if currentBook.id == -1 {
                    self.changeTimeDelegate?.changeTimeDelegate(status: RebookStatus.queryError, data: "没有预约记录")
                    return
                }
                
                //2.取消预约
                let header: HTTPHeaders = ["token": self.token]
                AF.request("\(self.BASE_URL)\(self.CANCEL_URI)/\(currentBook.id)", method: .get, headers: header).responseJSON { (data) in
                    print("2 == \(data)")
                    if json["status"] != "success" {
                       //取消失败
                        self.changeTimeDelegate?.changeTimeDelegate(status: RebookStatus.cancelError, data: json["message"].stringValue)
                        return
                    }
                    
                    //3.重新预约
                    URLCache.shared.removeAllCachedResponses()
                    Alamofire.Session.default.sessionConfiguration.requestCachePolicy = .reloadIgnoringCacheData
                    
                    let header: HTTPHeaders = [
                        "token": self.token,
                        "Cache-Control": "no-cache",
                        "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
                        "User-Agent": ""
                    ]
                    
                    let parameters: Parameters = [
                        "t": t,
                        "startTime": startTime,
                        "endTime": endTime,
                        "seat": self.lastBookSeatId,
                        "date": date,
                        "t2": t2
                    ]
                    
                    AF.request(self.BASE_URL + self.BOOK_URI, method: .post, parameters: parameters, headers: header).responseString { (data) in
                        print("3 == \(data) \(header) \(parameters)")
                        let responseString = data.value ?? ""
                        if responseString.prefix(1) != "{" {
                            //非JSON格式的预约失败
                            self.changeTimeDelegate?.changeTimeDelegate(status: RebookStatus.bookError, data: responseString)
                            return
                        }
                        
                        let json = JSON(data.data)
                        if json["status"] == "success" {
                            //预约成功
                            self.changeTimeDelegate?.changeTimeDelegate(status: RebookStatus.success, data: "")
                        }
                        else {
                            //JSON格式的预约失败
                            self.changeTimeDelegate?.changeTimeDelegate(status: RebookStatus.bookError, data: json["message"].stringValue)
                        }
                    }
                }
            }
            else {
                self.changeTimeDelegate?.changeTimeDelegate(status: RebookStatus.queryError, data: data.value ?? "")
            }
        }
        
        
        
        
    }
    
    
    
    
    
    
}
