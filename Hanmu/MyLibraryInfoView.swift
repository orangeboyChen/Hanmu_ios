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
                        HStack{
                            Text("学号")
                            Spacer()
                            Text(self.userId)
                        }
                        
                        HStack{
                            Text("姓名")
                            Spacer()
                            Text(self.userName)
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
    
    mutating func getUserInfoDelegate(data: AFDataResponse<Any>) {
        let json = JSON(data.data)
        self.isUserInfoLoading = false
        
        if json["status"] == "success" {
            withAnimation {
                self.userName = json["data"]["name"].string!
                self.isCheckedIn = json["data"]["checkedIn"].bool!
                self.userId = json["data"]["username"].string!
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
