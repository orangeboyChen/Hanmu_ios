//
//  HanmuRun.swift
//  Hanmu
//
//  Created by orangeboy on 2021/3/18.
//

import SwiftUI
import Combine

struct HanmuRunView: View, HanmuRunDelegate {
    
    
    @State var isSuggestData: Bool = true
    
    @State var customSpeed = ""
    
    @AppStorage("imeiCode", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var savedImeiCode: String = ""
    
    @AppStorage("lastDate", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var lastDate: String = "无"
    @AppStorage("lastSpeed", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var lastSpeed: String = "无"
    @AppStorage("lastCostTime", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var lastCostTime: String = "无"
    
    let spider: HanmuSpider = HanmuSpider.getInstance()
    
    var body: some View {
        Form {
            if savedImeiCode != "" {
                Section {
                    Toggle(isOn: $isSuggestData) {
                        Text("使用建议的数据")
                    }
                }
                
                if !isSuggestData {
                    Section(header: Text("跑步数据")) {
                        TextField("速度(m/s)", text: $customSpeed)
                            .keyboardType(.decimalPad)
                            .onReceive(Just(customSpeed), perform: { newValue in
                                let filtered = newValue.filter { "0123456789.".contains($0) }
                                if filtered != newValue {
                                    self.customSpeed = filtered
                                }
                            })
                    }
                }
                
                Section {
                    Button(action: {
                        if(self.savedImeiCode == ""){
                            BannerService.getInstance().showBanner(title: "似乎还没有有效的设备序列号", content: "没有已保存的设备序列号，请前往”我的“输入。", type: .Error)
                            return
                        }
                        
                        if !isSuggestData {
                            let number = Double(customSpeed)
                            if number == nil {
                                BannerService.getInstance().showBanner(title: "这似乎不是有效的速度", content: "请重新输入", type: .Error)
                                return
                            }
                            spider.run(speed: number!)
                        }
                        else {
                            spider.run()
                        }
                    }, label: {
                        Text("去跑步")
                    })
                }
            }
            else {
                Section(header: VStack{}) {
                    NavigationLink("添加跑步账号", destination: HanmuAccountView())
                }

            }

        }
        .navigationTitle("准备跑步")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: {
            self.spider.runDelegate = self
        })
    }
    
    mutating func onError(message: String) {
        BannerService.getInstance().showBanner(title: "发生了错误", content: message, type: .Error)
    }
    
    mutating func onSuccess(speed: Double, distance: Double, costTime: Int) {
        BannerService.getInstance().showBanner(title: "完成跑步", content: "", type: .Success)
        
        let dformatter = DateFormatter()
        dformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.lastDate = dformatter.string(from: Date())
        self.lastSpeed = String(speed)
        
        func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int) {
            return ((seconds) / 60, (seconds % 3600) % 60)
        }
        self.lastCostTime = String(secondsToHoursMinutesSeconds(seconds: costTime).0) + "' " + String(secondsToHoursMinutesSeconds(seconds: costTime).1) + "''"
    }
}

struct HanmuRun_Previews: PreviewProvider {
    static var previews: some View {
        HanmuRunView()
    }
}
