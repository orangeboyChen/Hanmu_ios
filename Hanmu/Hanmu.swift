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
    var id: String {title}
    var title: String
    var info: String
}

struct Hanmu: View, SpiderDelegate {

    

    @AppStorage("imeiCode") var savedImeiCode: String = ""
    @State private var alertInfo: AlertInfo?
    
    @AppStorage("lastDate") var lastDate: String = "无"
    @AppStorage("lastSpeed") var lastSpeed: String = "无"
    @AppStorage("lastCostTime") var lastCostTime: String = "无"
    
    var spider : Spider = Spider.getInstance()
    var user: User = User()
    
    
    var body: some View {
        NavigationView {
            VStack{
                Form {
                    Section {
                        Text("上次记录：" + self.lastDate )
                        Text("跑步速度：" + self.lastSpeed)
                        Text("跑步时间：" + self.lastCostTime)
                    }
                    Section{
                        Button(action: {
                                spider.login(imeiCode: savedImeiCode)
                            
                        }) {
                            Text("去跑步")
                            
                        }
                    }
                }.navigationTitle("跑步")
            }

        
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
            self.alertInfo = AlertInfo(title: "成功", info: "跑步成功")
            
            let dformatter = DateFormatter()
            dformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            self.lastDate = dformatter.string(from: Date())
            self.lastSpeed = String(speed)
            
            func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int) {
              return ((seconds) / 60, (seconds % 3600) % 60)
            }
            self.lastCostTime = String(secondsToHoursMinutesSeconds(seconds: costTime).0) + "分" + String(secondsToHoursMinutesSeconds(seconds: costTime).1) + "秒"
        }
        else{
            self.alertInfo = AlertInfo(title: "失败", info: "跑步失败")
        }
    }
}

struct Hanmu_Previews: PreviewProvider {
    static var previews: some View {
        Hanmu()
    }
}

