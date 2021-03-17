//
//  MyLibraryInfoView.swift
//  Hanmu
//
//  Created by orangeboy on 2021/3/15.
//

import SwiftUI
import Alamofire
import SwiftyJSON

struct MyLibraryInfoView: View, UserInfoDelegate {
    
    ///加载绑定
    @State var isUserInfoLoading: Bool = false
    
    //展示的信息
    @State var userName: String = ""
    @State var isCheckedIn: Bool = false
    @State var lastIn: String = "无"
    @State var lastOut: String = "无"
    @State var violationCount: Int = 1
    @State var lastInBuildingName: String = "无"
    
    //必要的存储信息
    @AppStorage("userId") var userId: String = ""
    @AppStorage("libraryToken") var token: String = ""
    
    ///爬虫
    private var spider: LibrarySpider = LibrarySpider.getInstance()
    
    ///弹窗提醒
    @State var alertInfo: AlertInfo?
    
    
    var body: some View {
        Form {
            Section(header: HStack{
                Text("账号信息")
                if self.isUserInfoLoading {
                    ProgressView()
                        .padding(.leading, 2.0)
                }
            }){

                if userName != "" {
                    Group {
                        HStack {
                            Text("学号")
                            Spacer()
                            Text(self.userId)
                        }
                        
                        HStack {
                            Text("姓名")
                            Spacer()
                            Text(self.userName)
                        }
                        
                        HStack {
                            Text("最近入馆时间")
                            Spacer()
                            Text(self.lastIn)
                        }
                        
                        HStack {
                            Text("最近出馆时间")
                            Spacer()
                            Text(self.lastOut)
                        }
                        
                        HStack {
                            Text("最近入馆")
                            Spacer()
                            Text(self.lastInBuildingName)
                        }
                        
                        HStack{
                            Text("是否在馆")
                            Spacer()
                            Text(self.isCheckedIn ? "是" : "否")
                        }
                    }
                }
                
                if token == "" {
                    NavigationLink(destination:
                                    AccountEditView()
                    ) {
                        Text("添加登录信息")
                    }
                }
                
            }
        }
        .navigationBarTitle("个人信息", displayMode: .inline)
        .onAppear(perform: {
            spider.userInfoDelegate = self
            if token != "" {
                spider.getUserInfo()
                isUserInfoLoading = true
            }
        })
        .alert(item: $alertInfo){item in
            Alert(title: Text(item.title), message: Text(item.info), dismissButton: .none)
        }
    }
    
    /**
     {
     "data" : {
     "lastInBuildingName" : null,
     "checkedIn" : false,
     "lastLogin" : "2021-03-16T23:37:14.000",
     "reservationStatus" : null,
     "lastIn" : null,
     "status" : "NORMAL",
     "username" : "2019302110194",
     "name" : "陈恩瀚",
     "violationCount" : 1,
     "username2" : null,
     "enabled" : true,
     "lastOut" : null,
     "id" : 175925,
     "lastInBuildingId" : null
     },
     "code" : "0",
     "status" : "success",
     "message" : ""
     }
     */
    
    mutating func getUserInfoDelegate(data: AFDataResponse<Any>) {
        let json = JSON(data.data)
        self.isUserInfoLoading = false
        
        print(json)
        
        if json["status"] == "success" {
            withAnimation {
                self.userName = json["data"]["name"].stringValue
                self.isCheckedIn = json["data"]["checkedIn"].boolValue
                self.userId = json["data"]["username"].stringValue
                
                self.lastInBuildingName = json["data"]["lastInBuildingName"].string ?? "无"
                
                let dformatter = DateFormatter()
                dformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                
                if json["data"]["lastIn"] != JSON.null {
                    let lastInDate = Formatter.iso8601.date(from: json["data"]["lastIn"].stringValue)
                    lastIn = dformatter.string(from: lastInDate!)
                }
                else {
                    lastIn = "无"
                }
                
                if json["data"]["lastOut"] != JSON.null {
                    let lastInDate = Formatter.iso8601.date(from: json["data"]["lastOut"].stringValue)
                    lastOut = dformatter.string(from: lastInDate!)
                }
                else {
                    lastOut = "无"
                }
                

            }
        }
        else{
            alertInfo = AlertInfo(title: "获取失败", info: json["message"].stringValue)
        }
    }
}

struct MyLibraryInfoView_Previews: PreviewProvider {
    static var previews: some View {
        MyLibraryInfoView()
    }
}

extension Formatter {
    static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}
