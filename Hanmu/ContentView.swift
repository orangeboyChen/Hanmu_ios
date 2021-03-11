//
//  ContentView.swift
//  Hanmu
//
//  Created by orangeboy on 2021/3/11.
//

import SwiftUI

struct ContentView: View {
    
    @State var imeiCode : String = "123"
    
    var body: some View {
        TabView() {
            Hanmu(imeiCode: $imeiCode)
                .tabItem {
                    Image(systemName: "flame")
                    Text("跑步")
                }.tag(1)
            My(imeiCode: $imeiCode).tabItem {
                Image(systemName: "person")
                Text("我的") }.tag(2)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(imeiCode: "23")
    }
}
