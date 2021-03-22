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
    @AppStorage("userId", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.xiaoqing")) var savedUserId: String = ""
    @AppStorage("password", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.xiaoqing")) var savedPassword: String = ""
    @AppStorage("libraryToken", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.xiaoqing")) var token: String = ""
    
    //用户信息
    @State var userId: String = ""
    @State var password: String = ""
    
    //加载绑定
    @State var isLoginLoading: Bool = false
    
    //弹窗绑定
    @State var alertInfo: AlertInfo?
    
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
                TextField("学号", text: self.$userId)
                SecureField("密码", text: self.$password)
            }
            if token != "" {
                Section {
                    
                    Button(action: {
                        withAnimation {
                            self.token = ""
                        }
                        self.alertInfo = AlertInfo(title: "删除成功", info: "")
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
        }).alert(item: $alertInfo) { info in
            Alert(title: Text(info.title), message: Text(info.info), dismissButton: .none)
        }
    }
    
    mutating func loginDelegate(data: AFDataResponse<Any>) {
        isLoginLoading = false
        let json = JSON(data.data)
        print(json)
        
        if json["status"].string ?? "" == "" {
            self.alertInfo = AlertInfo(title: "登录失败", info: "你可能被临时禁止登录，请稍后再试")
        }
        
        if json["status"] == "fail" {
            self.alertInfo = AlertInfo(title: "登录失败", info: json["message"].stringValue)
        }
        
        if json["status"] == "success" {
            withAnimation {
                savedUserId = userId
                savedPassword = password
                token = json["data"]["token"].stringValue
            }

            self.alertInfo = AlertInfo(title: "登录成功", info: "")
        }
    }
}

struct AccountEdit_Previews: PreviewProvider {
    static var previews: some View {
        LibraryAccountView()
    }
}

