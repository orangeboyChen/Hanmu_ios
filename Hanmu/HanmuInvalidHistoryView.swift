//
//  HanmuInvalidHistory.swift
//  Hanmu
//
//  Created by orangeboy on 2021/3/17.
//

import SwiftUI
import Alamofire
import SwiftyJSON

struct HanmuInvalidHistoryView: View, HanmuUserInfoDelegate {
    
    var spider: HanmuSpider = HanmuSpider.getInstance()
    
    @State var idd: Int = 30
    
    @State var invalidResultDictionary: Dictionary<String, [HanmuResult]> = [:]
    @State var invalidResultList: [HanmuResult] = []
    
    @State var isLoading: Bool = true
    @State var isMoreResult: Bool = true
    
    @State var invalidResultPageNum = 1
    @State var invalidResultStartPageSize = 10
    @State var invalidResultContinuePageSize = 10
    
    @State var alertInfo: AlertInfo?
    
    var body: some View {
        //        List {
        //            HStack {
        //                Spacer()
        //                ProgressView()
        //                Spacer()
        //            }
        //        }
        Form {
            
            ForEach(Array(invalidResultDictionary.keys.sorted(by: { (a: String, b: String) -> Bool in
                let aArray = a.components(separatedBy: "-")
                let bArray = b.components(separatedBy: "-")
                
                if Int(aArray[0])! > Int(bArray[0])!{
                    return true
                }
                else if Int(aArray[0])! < Int(bArray[0])! {
                    return false
                }
                else {
                    if Int(aArray[1])! > Int(bArray[1])! {
                        return true
                    }
                    else if Int(aArray[1])! < Int(bArray[1])! {
                        return false
                    }
                    else {
                        return Int(aArray[2])! > Int(bArray[2])!

                    }
                }
                
            })), id: \.self) { date in
                Section(header: Text(date)){
                    
                    
                    ForEach(invalidResultDictionary[date]!.sorted(by: {$0.hour > $1.hour}), id: \.self){ result in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(result.distance, specifier: "%g") km").font(.headline)
                                Text("\(result.hour)时").foregroundColor(.gray)
                            }
                            Spacer()
                            Text(result.costTime)
                        }
                        .padding(.vertical, 2.0)
                        .onAppear(perform: {
                            if result.id >= invalidResultList.count - 4 && !isLoading && isMoreResult {
                                
                                
                                isLoading = true
                                spider.getInvalidResult(pageNum: invalidResultPageNum, pageSize: invalidResultContinuePageSize)
                            }
                        })
                    }
                }
            }
            if isLoading {
                Section {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }
            
        }
        .navigationBarTitle("无效记录", displayMode: .inline)
        .onAppear(perform: {
            spider.userInfoDelegate = self
            initInvalidResult()
        })
        .alert(item: $alertInfo){info in
            Alert(title: Text(info.title), message: Text(info.info), dismissButton: .none)
        }
        
        
    }
    
    
    mutating func getValidResultDelegate(response: DataResponse<Any, AFError>) {
        
    }
    
    mutating func getInvalidResultDelegate(response: DataResponse<Any, AFError>) {
        
        isLoading = false
        
        let json = JSON(response.data)
        if json["Success"].boolValue {
            isMoreResult = !json["LastPage"].boolValue
            var i = invalidResultDictionary.count + 1
            json["listInValue"].forEach { (str: String, subJson: JSON) in
                var currentResult = HanmuResult()
                currentResult.costTime =
                    subJson["CostTime"].stringValue
                    .replacingOccurrences(of: "00时", with: "")
                    .replacingOccurrences(of: "时", with: "° ")
                    .replacingOccurrences(of: "分", with: "' ")
                    .replacingOccurrences(of: "秒", with: "''")
                currentResult.distance = subJson["CostDistance"].doubleValue / 1000
                currentResult.date = subJson["ResultDate"].stringValue
                    .replacingOccurrences(of: "年", with: "-")
                    .replacingOccurrences(of: "月", with: "-")
                    .replacingOccurrences(of: "日", with: "")
                currentResult.speed = subJson["Speed"].doubleValue
                currentResult.hour = subJson["ResultHour"].intValue
                currentResult.id = i
                i += 1
                
                invalidResultList.append(currentResult)
                if !invalidResultDictionary.keys.contains(currentResult.date) {
                    invalidResultDictionary[currentResult.date] = [currentResult]
                }
                else {
                    invalidResultDictionary[currentResult.date]?.append(currentResult)
                }
                
                
                
            }
            initResultId()
            invalidResultPageNum += 1
        }
        else {
            var message = json["ErrMsg"].stringValue
            if message.contains("验证码") {
                message = "请重新登录"
            }
            alertInfo = AlertInfo(title: "获取信息失败", info: message)
        }
        
    }
    
    func compareDate(a: String, b: String) -> Bool {
        let aArray = a.components(separatedBy: "-")
        let bArray = b.components(separatedBy: "-")
        
        if Int(aArray[0])! > Int(bArray[0])!{
            return true
        }
        else if Int(aArray[0])! < Int(bArray[0])! {
            return false
        }
        else {
            if Int(aArray[1])! > Int(bArray[1])! {
                return true
            }
            else if Int(aArray[1])! < Int(bArray[1])! {
                return false
            }
            else {
                return Int(aArray[2])! > Int(bArray[2])!
                
            }
        }
    }
    
    func initResultId() {
        invalidResultList.sort(by: {
            let a = $0.date
            let b = $1.date
            let aArray = a.components(separatedBy: "-")
            let bArray = b.components(separatedBy: "-")
            
            if Int(aArray[0])! > Int(bArray[0])!{
                return true
            }
            else if Int(aArray[0])! < Int(bArray[0])! {
                return false
            }
            else {
                if Int(aArray[1])! > Int(bArray[1])! {
                    return true
                }
                else if Int(aArray[1])! < Int(bArray[1])! {
                    return false
                }
                else if Int(aArray[1])! > Int(bArray[1])!{
                    return true
                }
                else {
                    return $0.hour > $1.hour
                }
            }
        })
        for i in 0..<invalidResultList.count {
            invalidResultList[i].id = i
        }
    }
    
    func initInvalidResult() {
        invalidResultDictionary = [:]
        invalidResultPageNum = 1
        invalidResultStartPageSize = 15
        isMoreResult = true
        invalidResultList = []
        
        isLoading = true
        spider.getInvalidResult(pageNum: invalidResultPageNum, pageSize: invalidResultStartPageSize)
    }
}

struct HanmuInvalidHistory_Previews: PreviewProvider {
    static var previews: some View {
        HanmuInvalidHistoryView()
    }
}

