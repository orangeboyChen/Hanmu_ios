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

struct Hanmu: View, HanmuSpiderDelegate, HanmuUserInfoDelegate {
    
    @AppStorage("imeiCode") var savedImeiCode: String = ""
    @State private var alertInfo: AlertInfo?
    
    @AppStorage("lastDate") var lastDate: String = "无"
    @AppStorage("lastSpeed") var lastSpeed: String = "无"
    @AppStorage("lastCostTime") var lastCostTime: String = "无"
    
    var spider : HanmuSpider = HanmuSpider.getInstance()
    var user: User = User()
    
    @State var validResult: [HanmuResult] = []
    @State var isMoreValidResult: Bool = true
    @State var validResultPageNum: Int = 1
    @State var validResultPageSize: Int = 5
    
    
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
                            return
                        }
                        spider.login(imeiCode: savedImeiCode)
                        
                    }) {
                        Text("去跑步")
                        
                    }
                }
                
                if savedImeiCode != "" {
                    Section(header: Text("有效记录")) {
                        ForEach(validResult, id: \.self) {result in
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("\(result.distance, specifier: "%g") km").font(.headline)
                                    Text("\(result.date)").foregroundColor(.gray)
                                }
                                Spacer()
                                Text(result.costTime)
                            }.padding(.vertical, 2.0)
                        }
                        if isMoreValidResult {
                            Button(action: {
                                withAnimation {
                                    validResultPageNum += 1
                                    spider.getValidResult(pageNum: validResultPageNum, pageSize: validResultPageSize)
                                }
                                
                            }, label: {
                                Text("更多")
                            })
                        }
                        
                        
                        //                    .popover(isPresented: .constant(true)) {
                        //
                        //                    }
                        
                    }
                    
                    Section {
                        NavigationLink(destination: HanmuInvalidHistory()) {
                            Text("无效记录")
                        }
                    }
                }
                
                
                
            }.navigationBarTitle("跑步")
        }.onAppear(perform: {
            self.spider.spiderDelegate = self
            self.spider.userInfoDelegate = self
            

            initValidResult()
            
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
            
            initValidResult()
        }
        else{
            self.alertInfo = AlertInfo(title: "跑步失败", info: "")
        }
    }
    
    mutating func getValidResultDelegate(response: DataResponse<Any, AFError>) {
        let json = JSON(response.data)
        print(json)
        if json["Success"].boolValue {
            withAnimation {
                isMoreValidResult = !json["LastPage"].boolValue
            }
            
            json["listValue"].forEach { (str: String, subJson: JSON) in
                var currentResult = HanmuResult()
                currentResult.costTime =
                    subJson["CostTime"].stringValue
                    .replacingOccurrences(of: "00时", with: "")
                    .replacingOccurrences(of: "分", with: "'")
                    .replacingOccurrences(of: "秒", with: "''")
                currentResult.distance = subJson["CostDistance"].doubleValue / 1000
                currentResult.date = subJson["ResultDate"].stringValue
                    .replacingOccurrences(of: "年", with: "-")
                    .replacingOccurrences(of: "月", with: "-")
                    .replacingOccurrences(of: "日", with: "")
                currentResult.speed = subJson["Speed"].doubleValue
                
                withAnimation {
                    validResult.append(currentResult)
                }
                
            }
            validResultPageNum += 1
        }
        else {
            var message = json["ErrMsg"].stringValue
            if message.contains("验证码") {
                message = "请重新登录"
            }
            alertInfo = AlertInfo(title: "获取信息失败", info: message)
        }
    }
    
    mutating func getInvalidResultDelegate(response: DataResponse<Any, AFError>) {
        
    }
    
    func initValidResult() {

            validResultPageNum = 1
            validResult = []
            isMoreValidResult = false
            spider.getValidResult(pageNum: validResultPageNum, pageSize: validResultPageSize)

    }
}

struct Hanmu_Previews: PreviewProvider {
    static var previews: some View {
        Hanmu()
    }
}


extension Double {
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}




