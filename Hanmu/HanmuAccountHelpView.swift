//
//  HanmuAccountHelpView.swift
//  Hanmu
//
//  Created by orangeboy on 2021/4/29.
//

import SwiftUI

struct HanmuAccountHelpView: View {
    var body: some View {
        NavigationView {
            VStack(alignment: .leading){
                Text("设备序列号用以标识用户身份，您必须确保拥有合法的登录账号以获取设备序列号。如果就绪，您可以通过包提取程序获得“汉姆”上的设备序列号，并在此输入。")
                
                Spacer()
                    .frame(height: 10)
                Text("如果你认为包提取程序是生物工程的一种操作过程，建议点击下方的“我需要更多帮助”寻找更合适的解决方案。")
                Spacer()
                    .frame(height: 20)
                Link(destination: URL(string: "https://www.baidu.com/s?wd=fiddler4%20iOS")!, label: {
                    Text("我需要更多帮助")
                })
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("汉姆帮助 - 跑步设备序列号")

        }


    }
}

struct HanmuAccountHelpView_Previews: PreviewProvider {
    static var previews: some View {
        HanmuAccountHelpView()
    }
}
