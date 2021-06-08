//
//  My.swift
//  Hanmu
//
//  Created by orangeboy on 2021/3/11.
//

import SwiftUI


struct My: View {
    
    @State var saveAlertContent: AlertInfo?
    
    @AppStorage("imeiCode", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var imeiCode: String = ""
    @AppStorage("userId", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var savedUserId: String = ""
    @AppStorage("password", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var savedPassword: String = ""
    @AppStorage("libraryToken", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var libraryToken: String = ""
    
    var body: some View {
        VStack{
            Form{
                Section(header:
                            Text("跑步"), footer:
                                HStack {
                                    SiriButtonView(shortcut: ShortcutManager.Shortcut.yourIntent)
                                        .frame(height: 60, alignment: .center)
                                }

                                
                ){
                    
                    NavigationLink(destination: HanmuAccountView()) {
                        Text("\(imeiCode == "" ? "添加" : "编辑")跑步账号")
                    }
                    

                }
                
                Section(header: Text("图书馆")){
                    NavigationLink(destination: LibraryAccountView()) {
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
        }
        .alert(item: $saveAlertContent){info in
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










