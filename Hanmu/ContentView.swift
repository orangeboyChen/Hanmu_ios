//
//  ContentView.swift
//  Hanmu
//
//  Created by orangeboy on 2021/3/11.
//

import SwiftUI


struct ContentView: View {
    
    
    @State
    var tabIndex: Int = UIDevice.current.userInterfaceIdiom == .pad ? 3 : 0
    
    let titles = ["跑步", "图书馆", "我的", "汉姆"]
    
    @State var bannerData: Banner.BannerData = Banner.BannerData(title: "", detail: "", type: .Info)
    
    @State var isShowBanner: Bool = false
    
    var bannerService = BannerService.getInstance()

    
    
    var body: some View {
        ZStack {
            
            NavigationView{
               TabView(selection: $tabIndex)
               {
                   HanmuView()
                       .tabItem {
                           Image(systemName: "flame")
                           Text("跑步")
                       }
                       .tag(0)
                   LibraryView()
                       .tabItem {
                           Image(systemName: "books.vertical")
                           Text("图书馆")
                       }.tag(1)
                   
                   My().tabItem {
                       Image(systemName: "person")
                       Text("我的") }
                       .tag(2)
               }
               .padding(.leading, UIDevice.current.userInterfaceIdiom == .pad ? 0.25 : 0)
               .navigationTitle(titles[tabIndex])
                
                if UIDevice.current.userInterfaceIdiom == .pad {
                   VStack {
                       Image("FirstPage")
                           .frame(width: 150)
                           .padding()
                       Text("请于左侧选择功能")
                           .padding()
                   }
               }

              
            }
            .onOpenURL(perform: { url in
               if url == URL(string: "hanmu://library") {
//                   tabIndex = 1
               }
            })
            
            VStack {
                Banner(data: $bannerData, isShow: $isShowBanner)
                    .padding()
                Spacer()
            }

        }.onAppear(perform: {
            bannerService.contentView = self
        })
    }
    

}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        
    }
}




