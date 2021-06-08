//
//  HanmuAccountView.swift
//  Hanmu
//
//  Created by orangeboy on 2021/3/18.
//

import SwiftUI

struct HanmuAccountView: View, HanmuLoginDelegate {

    
    
    @State var imeiCode: String = ""
//    @AppStorage("imeiCode", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var savedImeiCode: String = ""
    
    @AppStorage("imeiCode", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var savedImeiCode: String = ""
    

    
    @State var isLoginLoading: Bool = false
    
    @State var alertInfo: AlertInfo?
    
    let spider: HanmuSpider = HanmuSpider.getInstance()
    
    @State var isSheetShowing: Bool = false
    
    var body: some View {
        Form {
            Section(header: Text("账号"), footer:
                        Button(action: {
                            isSheetShowing = true
                        }) {
                            Text("如何获得设备序列号")
                        }
                        .sheet(isPresented: $isSheetShowing, content: {
                HanmuAccountHelpView()
            })
//                        .popover(isPresented: $isSheetShowing, content: {
//                            HanmuAccountHelpView()
//                        })
//
//                .sheet(isPresented: $isSheetShowing, content: {
//                            HanmuAccountHelpView()
//
//                        })
) {
                TextField("设备序列号", text: $imeiCode)
            }
            
            if savedImeiCode != "" {
                Section {
                    Button(action: {
                        withAnimation {
                            savedImeiCode = ""
                            imeiCode = ""
                        }
                    }, label: {
                        Text("删除设备序列号信息")
                    })
                    .foregroundColor(.red)
                }
            }

        }
        .navigationBarTitle("\(savedImeiCode == "" ? "添加" : "编辑")跑步账号", displayMode: .inline)
        .navigationBarItems(trailing:
                                Group {
                                    if !isLoginLoading {
                                        Button(action: {
                                            if(self.imeiCode.count != 32){
                                                self.alertInfo = AlertInfo(title: "验证失败", info: "序列号长度不正确")
                                                return
                                            }
                                            
                                            UIApplication.shared.windows
                                                .first { $0.isKeyWindow }?
                                                .endEditing(true)
                                            
                                            isLoginLoading = true
                                            spider.login(imeiCode: imeiCode)
                                        }, label: {
                                            Text("保存")
                                        })
                                    }
                                    else {
                                        ProgressView()
                                    }
                                })
        .alert(item: $alertInfo) { info in
            Alert(title: Text(info.title), message: Text(info.info), dismissButton: .none)
        }
        .onAppear(perform: {
            spider.loginDelegate = self
            imeiCode = savedImeiCode
        })
    }

    
    mutating func onSuccess() {
        withAnimation {
            isLoginLoading = false
            savedImeiCode = imeiCode
            alertInfo = AlertInfo(title: "验证成功", info: "")
        }
 
    }
    
    mutating func onError(message: String) {
        withAnimation {
            isLoginLoading = false
            alertInfo = AlertInfo(title: "验证失败", info: "请尝试重新获取序列号")
        }

    }
}

struct HanmuAccountView_Previews: PreviewProvider {
    static var previews: some View {
        HanmuAccountView()
    }
}

