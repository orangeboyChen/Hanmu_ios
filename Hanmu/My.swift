//
//  My.swift
//  Hanmu
//
//  Created by orangeboy on 2021/3/11.
//

import SwiftUI


struct My: View {

    
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
                            BannerService.getInstance().showBanner(title: "完成", content: "登录信息已清空", type: .Success)
                        }) {
                            Image(systemName: "person.fill.xmark")
                            Text("清空登录信息")
                        }
                    }))
                }
            }
        }
        .navigationTitle("我的")
        
    }
    
    func modifyImei(){
        
    }
}

struct My_Previews: PreviewProvider {
    static var previews: some View {
        My()
    }
}










