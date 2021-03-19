//
//  Hanmu.swift
//  Hanmu
//
//  Created by orangeboy on 2021/3/11.
//

import SwiftUI
import Alamofire
import SwiftyJSON



struct HanmuView: View, HanmuUserInfoDelegate {
    @AppStorage("imeiCode", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.xiaoqing")) var savedImeiCode: String = ""
    @State private var alertInfo: AlertInfo?
    
    @AppStorage("lastDate", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.xiaoqing")) var lastDate: String = "无"
    @AppStorage("lastSpeed", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.xiaoqing")) var lastSpeed: String = "无"
    @AppStorage("lastCostTime", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.xiaoqing")) var lastCostTime: String = "无"
    
    var spider : HanmuSpider = HanmuSpider.getInstance()
    var user: User = User()
    
    @State var validResult: [HanmuResult] = []
    @State var isMoreValidResult: Bool = true
    @State var validResultPageNum: Int = 1
    @State var validResultPageSize: Int = 3
    
    
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
                    NavigationLink(destination: HanmuRunView()) {
                        Text("去跑步")
                    }
                }
                if savedImeiCode != "" {
                    Section(header: Text("有效记录")) {
                        ForEach(validResult, id: \.self) {result in
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("\(result.distance, specifier: "%g") km").font(.headline)
                                    Text("\(result.date) \(result.hour)时").foregroundColor(.gray)
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
                    }
                    
                    Section {
                        NavigationLink(destination: HanmuInvalidHistoryView()) {
                            Text("无效记录")
                        }
                    }
                }
                
                
                
            }.navigationBarTitle("跑步")
        }.onAppear(perform: {
            self.spider.userInfoDelegate = self
            
            initValidResult()
            
        }).alert(item: $alertInfo){info in
            Alert(title: Text(info.title), message: Text(info.info), dismissButton: .none)
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
                    .replacingOccurrences(of: "分", with: "' ")
                    .replacingOccurrences(of: "秒", with: "''")
                currentResult.distance = subJson["CostDistance"].doubleValue / 1000
                currentResult.date = subJson["ResultDate"].stringValue
                    .replacingOccurrences(of: "年", with: "-")
                    .replacingOccurrences(of: "月", with: "-")
                    .replacingOccurrences(of: "日", with: "")
                currentResult.speed = subJson["Speed"].doubleValue
                currentResult.hour = subJson["ResultHour"].intValue
                
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
        
        if savedImeiCode != "" {
            spider.getValidResult(pageNum: validResultPageNum, pageSize: validResultPageSize)
        }
    }
}

struct Hanmu_Previews: PreviewProvider {
    static var previews: some View {
        HanmuView()
    }
}


extension Double {
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}




