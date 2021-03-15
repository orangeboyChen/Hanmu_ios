//
//  Hanmu.swift
//  Hanmu
//
//  Created by orangeboy on 2021/3/11.
//

import SwiftUI
import Alamofire
import SwiftyJSON

struct AlertInfo: Identifiable {
    var id: String {title;}
    var title: String
    var info: String
}

struct Hanmu: View, HanmuSpiderDelegate {

    

    @AppStorage("imeiCode") var savedImeiCode: String = ""
    @State private var alertInfo: AlertInfo?
    
    @AppStorage("lastDate") var lastDate: String = "无"
    @AppStorage("lastSpeed") var lastSpeed: String = "无"
    @AppStorage("lastCostTime") var lastCostTime: String = "无"
    
    var spider : HanmuSpider = HanmuSpider.getInstance()
    var user: User = User()
    
    
    var body: some View {
        
            VStack{
                Form {
                    if lastDate != "无" {
                        Section(header: Text("上次记录")) {
                            HStack{
                                VStack(alignment: .leading){
                                    Text(lastSpeed + " 米每秒").font(.headline)
                                    Text(lastDate)
                                }
                                Spacer()
                                Text(lastCostTime)
                            }
                            .padding(.vertical)
                        }
                    }

                    Section{
                        Button(action: {
                            if(self.savedImeiCode == ""){
                                self.alertInfo = AlertInfo(
                                    title: "似乎还没有IMEI",
                                    info: "您还未输入IMEI，请前往”我的“输入。")
                                return;
                            }
                                spider.login(imeiCode: savedImeiCode)
                            
                        }) {
                            Text("去跑步")
                            
                        }
                    }
                }.navigationBarTitle("跑步")
            }.onAppear(perform: {
            self.spider.delegate = self
        }).alert(item: $alertInfo){info in
            Alert(title: Text(info.title), message: Text(info.info), dismissButton: .none)
        }
    }
    
    mutating func loginDelegate(response: DataResponse<Any, AFError>) {
        let json = JSON(response.data as Any)
        print(json)
        if(json["Success"] == true){
            self.user.token = json["Data"]["Token"].string!
            spider.getUserInfo(token: user.token)
        }
        else{
            self.alertInfo = AlertInfo(title: "失败", info: savedImeiCode + "似乎无效。请尝试重新获取IMEI")
        }
    }
    
    mutating func getUserInfoDelegate(response: DataResponse<Any, AFError>) {
        let json = JSON(response.data as Any)
        print(json)
        if(json["Success"] == true){
            self.user.minSpeed = json["Data"]["SchoolRun"]["MinSpeed"].doubleValue
            self.user.maxSpeed = json["Data"]["SchoolRun"]["MaxSpeed"].doubleValue
            self.user.distance = Int32(json["Data"]["SchoolRun"]["Lengths"].intValue)
            spider.getRunId(token: user.token, distance: user.distance)
        }
        else{
            self.alertInfo = AlertInfo(title: "失败", info: "获取用户信息失败")
        }
        
    }
    
    mutating func getRunIdDelegate(response: DataResponse<Any, AFError>) {
        let json = JSON(response.data as Any)
        print(json)
        if(json["Success"] == true){
            self.user.runId = json["Data"]["RunId"].string!
            spider.postFinishRunning(user: user)
        }
        else{
            self.alertInfo = AlertInfo(title: "失败", info: "获取RunId失败")
        }
    }
    
    func postDataDelegate(response: DataResponse<Any, AFError>, speed: Double, distance: Double, costTime: Int) {
        let json = JSON(response.data as Any)
        print(json)
        if(json["Success"] == true){
            self.alertInfo = AlertInfo(title: "跑步成功", info: "")
            
            let dformatter = DateFormatter()
            dformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            self.lastDate = dformatter.string(from: Date())
            self.lastSpeed = String(speed)
            
            func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int) {
              return ((seconds) / 60, (seconds % 3600) % 60)
            }
            self.lastCostTime = String(secondsToHoursMinutesSeconds(seconds: costTime).0) + "' " + String(secondsToHoursMinutesSeconds(seconds: costTime).1) + "''"
        }
        else{
            self.alertInfo = AlertInfo(title: "跑步失败", info: "")
        }
    }
}

struct Hanmu_Previews: PreviewProvider {
    static var previews: some View {
        Hanmu()
    }
}

