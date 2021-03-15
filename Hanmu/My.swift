//
//  My.swift
//  Hanmu
//
//  Created by orangeboy on 2021/3/11.
//

import SwiftUI


struct My: View {
    
    @State var imeiCode: String = ""
    @State var saveAlertContent: AlertInfo?
    
    @AppStorage("imeiCode") var savedImeiCode: String = ""
    @AppStorage("userId") var savedUserId: String = ""
    @AppStorage("password") var savedPassword: String = ""
    @AppStorage("libraryToken") var libraryToken: String = ""
    
    var body: some View {
            VStack{
                Form{
                    Section(header: Text("跑步")){
                        TextField("设备序列号", text: $imeiCode)
                    
                        Button(action: {
                            print(self.imeiCode.count)
                            if(self.imeiCode.count != 32){
                                self.saveAlertContent = AlertInfo(title: "失败", info: "序列号长度不正确")
                                return
                            }
                            
                            UIApplication.shared.windows
                                        .first { $0.isKeyWindow }?
                                        .endEditing(true)
                            
                            self.savedImeiCode = imeiCode
                            self.saveAlertContent = AlertInfo(title: "成功", info: "你可以愉快地跑步了")
                        }) {
                            Text("好").contextMenu(ContextMenu(menuItems: {
                                Button(action: {
                                    self.savedImeiCode = ""
                                    self.imeiCode = ""
                                    self.saveAlertContent = AlertInfo(title: "完成", info: "已为您清空所有序列号信息")
                                }) {
                                    Image(systemName: "person.fill.xmark")
                                    Text("清空序列号信息")
                                }
                            }))
                        }
                    }
                    
                    Section(header: Text("图书馆")){
                        NavigationLink(destination: MyLibraryInfoView()) {
                            Text("个人信息")
                        }
                        NavigationLink(destination: AccountEditView()) {
                            Text("\(libraryToken == "" ? "添加" : "编辑")登录信息")
                        }.contextMenu(ContextMenu(menuItems: {
                            Button(action: {
                                self.savedUserId = ""
                                self.savedPassword = ""
                                self.libraryToken = "" 
                                self.saveAlertContent = AlertInfo(title: "完成", info: "已为您清空登录信息")
                            }) {
                                Image(systemName: "person.fill.xmark")
                                Text("清空登录信息")
                            }
                        }))
                    }
                }
        }.onAppear(perform: {
            self.imeiCode = self.savedImeiCode
        }).alert(item: $saveAlertContent){info in
            Alert(title: Text(info.title), message: Text(info.info), dismissButton: .none)
        }
        
    }
    
    func modifyImei(){
        
    }
}

struct My_Previews: PreviewProvider {
    static var previews: some View {
        My()
    }
}









