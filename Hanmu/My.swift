//
//  My.swift
//  Hanmu
//
//  Created by orangeboy on 2021/3/11.
//

import SwiftUI


struct My: View {
    
    @Binding var imeiCode : String
    @State var saveAlertShow: Bool = false
    
    @AppStorage("imeiCode") var savedImeiCode: String = ""

    
    var body: some View {
        NavigationView{
            VStack{
                Form{
                    Section{
                        TextField("设备序列号", text: $imeiCode)
                        Button(action: {
                            self.savedImeiCode = imeiCode
                            self.saveAlertShow.toggle()
                        }) {
                            Text("好")
                        }
                    }
                }
                
            }.navigationTitle("我的")
        }.onAppear(perform: {
            self.imeiCode = self.savedImeiCode
        }).alert(isPresented: self.$saveAlertShow, content: {
            Alert(title: Text("保存成功"))
        })
        
    }
    
    func modifyImei(){
        
    }
}

struct My_Previews: PreviewProvider {
    static var previews: some View {
        My(imeiCode: Binding.constant("123"))
    }
}








