//
//  AccountEditView.swift
//  Hanmu
//
//  Created by orangeboy on 2021/3/13.
//

import SwiftUI
import Alamofire
import SwiftyJSON

struct LibraryAccountView: View, LoginDelegate {
    //存储的信息
    @AppStorage("userId", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var savedUserId: String = ""
    @AppStorage("password", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var savedPassword: String = ""
    @AppStorage("libraryToken", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var token: String = ""
    
    @AppStorage("libraryInfoCache", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var libraryInfoCache = ""
    
    @AppStorage("roomInfoCache", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var roomInfoCache = ""
    
    @AppStorage("lastSelectedBuildingId", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var savedBuildingId: Int = -1
    @AppStorage("lastSelectedRoomId", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var savedRoomId: Int = -1
    
    //用户信息
    @State var userId: String = ""
    @State var password: String = ""
    
    //加载绑定
    @State var isLoginLoading: Bool = false
    
    
    //爬虫
    private var spider: LibrarySpider = LibrarySpider.getInstance()
    
    
    
    var body: some View {
        Form{
            Section(header: Text("账号"),
                    footer: HStack {
                        if token != "" {
                            Text("登录序列号：\(token)")
                        }
            }) {
                TextField("学号", text: $userId)
                SecureField("密码", text: $password)
            }
            if token != "" {
                Section {
                    
                    Button(action: {
                        withAnimation {
                            self.token = ""
                            self.libraryInfoCache = ""
                            self.roomInfoCache = ""
                            self.savedBuildingId = -1
                            self.savedRoomId = -1
                        }
                        BannerService.getInstance().showBanner(title: "删除成功", content: "", type: .Success)
                    }, label: {
                        Text("删除登录序列号").foregroundColor(.red)
                    })
                }
            }


        }.navigationBarTitle("登录信息", displayMode: .inline)
        .navigationBarItems(trailing:
                                Group {
                                    if !isLoginLoading {
                                        Button(action: {
                                            isLoginLoading = true
                                            spider.login(userId: userId, password: password)
                                        }, label: {
                                            Text("登录")
                                        })
                                    }
                                    else {
                                        ProgressView()
                                    }
                                })


//                                .disabled(!(userId != "" && password != "" && userId != savedUserId && password != savedPassword)))
        .onAppear(perform: {
            spider.loginDelegate = self
            self.userId = self.savedUserId
            self.password = self.savedPassword
            
            print("suid: \(self.savedUserId) spwd: \(self.savedPassword)")
        })
    }
    
    mutating func loginDelegate(data: AFDataResponse<Any>) {
        isLoginLoading = false
        let json = JSON(data.data)
        print(json)
        
        if json["status"].string ?? "" == "" {
            BannerService.getInstance().showBanner(title: "登录失败", content: "你可能被临时禁止登录，请稍后再试", type: .Error)
        }
        
        if json["status"] == "fail" {
            BannerService.getInstance().showBanner(title: "登录失败", content: json["message"].stringValue, type: .Error)
        }
        
        if json["status"] == "success" {
            withAnimation {
                savedUserId = userId
                savedPassword = password
                token = json["data"]["token"].stringValue
            }
            BannerService.getInstance().showBanner(title: "登录成功", content: "", type: .Success)
        }
    }
}

struct AccountEdit_Previews: PreviewProvider {
    static var previews: some View {
        LibraryAccountView()
    }
}

