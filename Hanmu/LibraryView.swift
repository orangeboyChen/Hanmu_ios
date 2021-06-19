//
//  LibraryView.swift
//  Hanmu
//
//  Created by orangeboy on 2021/3/13.
//

import SwiftUI
import Alamofire
import SwiftyJSON
import WidgetKit

struct LibraryView: View, HistoryDelegate, BookControlDelegate, LoginDelegate {

    var spider: LibrarySpider = LibrarySpider.getInstance()
    
    @StateObject var displayBook: Book = Book()
    
    @State var isDisplayBookLoading: Bool = false
    @State var isCancelOrStopLoading: Bool = false
    @State var isLoginLoading: Bool = false

    
    @State var isBookViewActive: Bool = false
    @State var isRebookViewActive: Bool = false

    @State var isHistoryViewActive: Bool = false
    @State var isLibraryInfoViewActive: Bool = false
    
    @AppStorage("libraryToken", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var token: String = ""
    

    /**
     /**
      "id": 11196044,
      "date": "2021-3-15",
      "begin": "08:00",
      "end": "08:30",
      "awayBegin": null,
      "awayEnd": null,
      "loc": "信息馆1层西区3C创客咖啡区007号",
      "stat": "RESERVE"
      */
     */
    
    
    
    
    
    var body: some View {
        Form{
            
            if token != "" {
                if isDisplayBookLoading || displayBook.id != -1 {
                    Section(header: HStack {
//                        Text("\(isLoginLoading ? "正在登录" : "当前预约")")
                        if isDisplayBookLoading {
                            ProgressView()
                                .padding(.leading, 2.0)
                        }
                        
                    } ){
                        if displayBook.id != -1 {
                            HStack{
                                VStack(alignment: .leading){
                                    Text(displayBook.loc!)
                                        .font(.headline)
                                    Text("\(displayBook.date!) \(displayBook.begin!) - \(displayBook.end!)")
                                    if displayBook.stat == "AWAY" {
                                        Text("离开于\(displayBook.awayBegin!)")
                                            .foregroundColor(.orange)
                                    }
                                    
                                }
                                Spacer()
                                Group {
                                    if displayBook.stat == "RESERVE" {
                                        Text("已预约")
                                            .foregroundColor(.blue)
                                    }
                                    else if displayBook.stat == "CHECK_IN" {
                                        Text("已入馆")
                                            .foregroundColor(.green)
                                    }
                                    else if displayBook.stat == "AWAY" {
                                        Text("已暂离")
                                            .foregroundColor(.blue)
                                    }
                                }
                                
                                
                            }
                            .padding(.vertical)
                            Group {
//                                if displayBook.stat == "RESERVE" {
//                                    Button(action: {
//                                        isCancelOrStopLoading = true
//                                        spider.cancel(id: String(self.displayBook.id))
//                                        WidgetCenter.shared.reloadTimelines(ofKind: "LibraryWidget")
//                                    }, label: {
//                                        HStack {
//                                            Text("取消预约")
//
//
//                                            Spacer()
//                                            if isCancelOrStopLoading {
//                                                ProgressView()
//                                            }
//                                        }
//                                    }).disabled(isCancelOrStopLoading)
//                                    .foregroundColor(isCancelOrStopLoading ? .gray : .red)
//                                }
//                                else if displayBook.stat == "CHECK_IN" {
//                                    Button(action: {
//
//                                        spider.stop()
//                                    }, label: {
//                                        HStack {
//                                            Text("结束使用")
//
//                                            Spacer()
//                                            if isCancelOrStopLoading {
//                                                ProgressView()
//                                            }
//                                        }
//
//                                    })
//                                    .disabled(isCancelOrStopLoading)
//                                }
//                                else if displayBook.stat == "AWAY" {
//                                    Button(action: {
//                                        isCancelOrStopLoading = true
//                                        spider.stop()
//                                    }, label: {
//                                        HStack {
//                                            Text("结束使用")
//
//
//                                            Spacer()
//                                            if isCancelOrStopLoading {
//                                                ProgressView()
//                                            }
//                                        }
//                                    }).disabled(isCancelOrStopLoading)
//                                }
                                
                                NavigationLink(destination: RebookView(currentBook: displayBook, isRebookViewActive: $isRebookViewActive), isActive: $isRebookViewActive) {
                                    HStack {
                                        Text("变更预约")
                                            .foregroundColor(.blue)
                                    }
                                }
                                

                                
                            }
                        }
                    }
                }
                
                
                Section {
                    NavigationLink(
                        destination: BookView(isBookViewActive: self.$isBookViewActive),
                        isActive: self.$isBookViewActive) {
                        Text("预约")
                    }
                    .isDetailLink(false)
                }
                
                Section {
                    NavigationLink(destination: LibraryHistory(isActive: $isHistoryViewActive), isActive: $isHistoryViewActive) {
                        Text("历史预约记录")
                    }
                }
                
                Section {
                    NavigationLink(
                        destination: MyLibraryInfoView(isActive: $isLibraryInfoViewActive), isActive: $isLibraryInfoViewActive) {
                        Text("个人信息")
                    }
                }
            }
            else {
                Section {
                    NavigationLink(destination: LibraryAccountView()) {
                        Text("添加登录信息")
                    }
                }

            }
            


            


        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear(perform: {
            WidgetCenter.shared.reloadTimelines(ofKind: "LibraryWidget")
            spider.historyDelegate = self
            spider.bookControlDelegate = self
            spider.loginDelegate = self
            
            if spider.token != "" {
                withAnimation {
                    isDisplayBookLoading = true
                }

                spider.history(pageNum: 1, pageSize: 10)
            }
            
        })
        
    }
    
    /**
     重新登录获取token后
     */
    mutating func loginDelegate(data: AFDataResponse<Any>) {
        isDisplayBookLoading = false
        isLoginLoading = false
        let json = JSON(data.data)
        print(json)
        
        if json["status"].string ?? "" == "" {
            BannerService.getInstance().showBanner(title: "登录失败", content: "你可能被临时禁止登录，请稍后再试", type: .Error)
        }
        
        if json["status"] == "fail" {
            BannerService.getInstance().showBanner(title: "登录失败", content: json["message"].stringValue, type: .Error)
        }
        
        if json["status"] == "success" {
            isDisplayBookLoading = true
            spider.history(pageNum: 1, pageSize: 10)
        }
    }
    
    mutating func getHistoryDelegate(data: AFDataResponse<String>) {
        withAnimation {
            isDisplayBookLoading = false
            
            if data.value == "ERROR: Abnormal using detected!!!" {
                token = ""
                spider.login()
                isDisplayBookLoading = true
                isLoginLoading = true
                return
            }
            
            let json = JSON(parseJSON: data.value ?? "")
            if json["status"] == "success" {
                displayBook.clear()
                
                json["data"]["reservations"].forEach { (str: String, subJson: JSON) in
                    let status = subJson["stat"]
                    if status == "RESERVE" || status == "CHECK_IN" || status == "AWAY" {
                        displayBook.id = subJson["id"].intValue
                        displayBook.date = subJson["date"].stringValue
                        displayBook.begin = subJson["begin"].stringValue
                        displayBook.end = subJson["end"].stringValue
                        displayBook.awayBegin = subJson["awayBegin"].stringValue
                        displayBook.awayEnd = subJson["awayEnd"].stringValue
                        displayBook.stat = subJson["stat"].stringValue
                        displayBook.loc = subJson["loc"].stringValue
                    }
                }
            }

        }


    }
    
    mutating func cancelDelegate(data: AFDataResponse<Any>) {
        let json = JSON(data.data)
        print(json)
        
        withAnimation {
            isCancelOrStopLoading = false
            
            if json["status"] == "success" {
                displayBook.clear()
            }
            else {
                BannerService.getInstance().showBanner(title: "操作失败", content: json["message"].stringValue, type: .Error)

            }
        }

    }
    
    mutating func stopDelegate(data: AFDataResponse<Any>) {
        let json = JSON(data.data)
        print(json)
        withAnimation {
            isCancelOrStopLoading = false
            
            if json["status"] == "success" {
                BannerService.getInstance().showBanner(title: "已释放座位", content: "", type: .Success)
                displayBook.clear()
            }
            else {
                BannerService.getInstance().showBanner(title: "操作失败", content: json["message"].stringValue, type: .Error)
            }
        }
        
    }
}

struct Library_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}
