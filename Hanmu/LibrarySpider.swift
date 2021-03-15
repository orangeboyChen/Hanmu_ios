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
    mutating func getFreeRoomDelegate(data: AFDataResponse<Any>)
    mutating func getRoomDetailDelegate(data: AFDataResponse<String>)
    mutating func getIsValidTokenDelegate(data: AFDataResponse<Any>)
    mutating func getSeatDetailDelegate(data: AFDataResponse<Any>)
    mutating func searchSeatDelegate(data: AFDataResponse<Any>)
    mutating func bookDelegate(data: AFDataResponse<String>)
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
    
    //爬取需要的信息
    @AppStorage("libraryToken") var token: String = ""
    
    
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
    
    public func getFreeRoom() {
        let header: HTTPHeaders = ["token": token]
        AF.request(BASE_URL + ROOM_INFO_URI, method: .get, headers: header).responseJSON { (response) in
            self.delegate?.getFreeRoomDelegate(data: response)
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
        let header: HTTPHeaders = ["token": self.token]
        let parameters: Parameters = [
            "t": t,
            "startTime": startTime,
            "endTime": endTime,
            "seat": seat,
            "date": date,
            "t2": t2
        ]
        
        AF.request(self.BASE_URL + self.BOOK_URI, method: .post, parameters: parameters, headers: header).responseString { (response) in
            self.delegate?.bookDelegate(data: response)
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
        AF.request(BASE_URL + HISTORY_URI + String(pageNum) + "/" + String(pageSize), method: .get, headers: header).responseJSON { (response) in
            self.historyDelegate?.getHistoryDelegate(data: response)
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
    
}
