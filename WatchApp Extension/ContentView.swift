//
//  ContentView.swift
//  WatchApp Extension
//
//  Created by orangeboy on 2021/6/22.
//

import SwiftUI
import Alamofire
import SwiftyJSON

class CurrentBook: ObservableObject {
    @Published var date: Date = Date()
    @Published var id: Int = -1
    @Published var displayDate: String = ""
    @Published var seatNum: String = ""
    @Published var loc: String = ""
    @Published var stat: String = ""
    @Published var bookDate: String = ""
    @Published var begin: String = ""
    @Published var end: String = ""
    @Published var awayBegin: String = ""
    @Published var awayEnd: String = ""
    
    func clear() {
        date = Date()
        id = -1
        displayDate = ""
        seatNum = ""
        loc = ""
        stat = ""
        bookDate = ""
        begin = ""
        end = ""
        awayBegin = ""
        awayEnd = ""
    }
}


struct ContentView: View, HistoryDelegate, BookControlDelegate, ConnectionDelegate {
    mutating func didReceiveLibraryToken() {
        isUpdating = true
        spider.history(pageNum: 1, pageSize: 10)
    }
    
    
    let spider = LibrarySpider.getInstance()

    var phoneConnection = ConnectionWatch.getInstance()
    
    @AppStorage("libraryToken", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var token: String = ""
    @AppStorage("password", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var password: String = ""
    @AppStorage("userId", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var userId: String = ""
    
    @State var isUpdating: Bool = false
    @State var isStopping: Bool = false
    
    @StateObject var displayBook: CurrentBook = CurrentBook()
    
    
    mutating func getHistoryDelegate(data: AFDataResponse<String>) {
    
        withAnimation {
            isUpdating = false
            
            
//            if data.value == "ERROR: Abnormal using detected!!!" {
//                token = ""
//                spider.login()
//                isDisplayBookLoading = true
//                isLoginLoading = true
//                return
//            }
            
            let json = JSON(parseJSON: data.value ?? "")
            print(json)
            if json["status"] == "success" {
                displayBook.clear()
                
                json["data"]["reservations"].forEach { (str: String, subJson: JSON) in
                    let status = subJson["stat"]
                    if status == "RESERVE" || status == "CHECK_IN" || status == "AWAY" {
                        displayBook.id = subJson["id"].intValue
                        displayBook.displayDate = subJson["date"].stringValue
                        displayBook.begin = subJson["begin"].stringValue
                        displayBook.end = subJson["end"].stringValue
                        displayBook.awayBegin = subJson["awayBegin"].stringValue
                        displayBook.awayEnd = subJson["awayEnd"].stringValue
                        displayBook.stat = subJson["stat"].stringValue
                        displayBook.loc = subJson["loc"].stringValue
                        
                        var rawLoc = subJson["loc"].stringValue
                        
                        //正则表达式匹配三位数字
                        let range = NSRange(location: 0, length: rawLoc.count)
                        let pattern = "\\d{3}"
                        let regex = try! NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
                        let resArray = regex.matches(in: rawLoc, options: [.reportProgress], range: range)
                        
                        if resArray.count > 0 {
                            let seatRange = resArray[resArray.count - 1].range
                            let temp = rawLoc
                            let seatNum = temp.dropFirst(seatRange.location).prefix(seatRange.length)
                            
                            rawLoc = rawLoc.replacingOccurrences(of: seatNum + "号", with: "")
                            
                            displayBook.seatNum = String(seatNum)
                            displayBook.loc = rawLoc
                        }
                        else {
                            displayBook.seatNum = ""
                            displayBook.loc = rawLoc
                        }
                    }
                }
            }

        }

    }
    
    mutating func cancelDelegate(data: AFDataResponse<Any>) {
        stopDelegate(data: data)
    }
    
    mutating func stopDelegate(data: AFDataResponse<Any>) {
        withAnimation {
            isStopping = false
            isUpdating = true
            spider.history(pageNum: 1, pageSize: 10)
        }
    }
    
    
    @StateObject var book: Book = Book()
    
    var body: some View {
        Group {
            HStack {
                if isUpdating {
                    ProgressView("正在获取数据")
                }
                else if displayBook.id != -1 {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(displayBook.seatNum)
                                .font(.title)
                            Spacer()
                            
                            if displayBook.stat == "RESERVE" {
                                Text("已预约")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                            }
                            else if displayBook.stat == "CHECK_IN" {
                                Text("已入馆")
                                    .foregroundColor(.green)
                                    .font(.caption)
                            }
                            else if displayBook.stat == "AWAY" {
                                Text("于\(displayBook.awayBegin)暂离")
                                    .foregroundColor(.orange)
                                    .font(.caption)
                            }

                        }

                        Text(displayBook.loc)
                        Text("\(displayBook.begin)-\(displayBook.end)")
                        Spacer()
                        Button(action: {
                            if displayBook.stat == "RESERVE" {
                                spider.cancel(id: String(displayBook.id))
                            }
                            else if displayBook.stat == "AWAY" || displayBook.stat == "CHECK_IN" {
                                spider.stop()
                            }
                            isStopping = true
                            
                        }, label: {
                            if isStopping {
                                Text("正在请求")
                            }
                            else if displayBook.stat == "RESERVE" {
                                Text("取消预约")
                            }
                            else if displayBook.stat == "CHECK_IN" {
                                Text("结束使用")
                            }
                            else if displayBook.stat == "AWAY" {
                                Text("结束使用")
                            }
                        }).disabled(isStopping)
                    }
                    .padding(.horizontal)
                    Spacer()
                }
                else {
                    Text("暂无有效预约")
                }

            }
        }.onAppear(perform: {
            spider.historyDelegate = self
            spider.bookControlDelegate = self
            
            phoneConnection.connectionDelegate = self
            
            if token != "" {
                isUpdating = true
                spider.history(pageNum: 1, pageSize: 10)
            }

            
            print(userId)
            print(token)
            

        })

        

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
