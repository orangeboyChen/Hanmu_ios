//
//  ContentView.swift
//  Hanmu
//
//  Created by orangeboy on 2021/3/11.
//

import SwiftUI



struct ContentView: View {
    
    
    @State var tabIndex: Int = 1
    let titles = ["跑步", "图书馆", "我的"]

    
    
    var body: some View {
         NavigationView{
            TabView(selection: $tabIndex)
            {
                Hanmu()
                    .tabItem {
                        Image(systemName: "flame")
                        Text("跑步")
                    }
                    .tag(1)
                LibraryView()
                    .tabItem {
                        Image(systemName: "books.vertical")
                        Text("图书馆")
                    }.tag(2)
                
                My().tabItem {
                    Image(systemName: "person")
                    Text("我的") }
                    .tag(3)
            }
            .navigationTitle(titles[tabIndex - 1])
            .padding(.leading, 0.25)
         }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



