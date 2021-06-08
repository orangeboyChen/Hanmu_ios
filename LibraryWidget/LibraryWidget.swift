//
//  LibraryWidget.swift
//  LibraryWidget
//
//  Created by orangeboy on 2021/3/19.
//

import WidgetKit
import SwiftUI
import Intents
import Alamofire
import SwiftyJSON

struct Provider: IntentTimelineProvider, HistoryDelegate, LoginDelegate {

    
    
    var spider: LibrarySpider = LibrarySpider.getInstance()
    
    //异步任务
    let group = DispatchGroup()
    let dispatchQueue = DispatchQueue.global()
    
    static var displayBook: CurrentBookEntry = CurrentBookEntry()
    
    mutating func loginDelegate(data: AFDataResponse<Any>) {
        let json = JSON(data.data)
        
        if json["status"].string ?? "" == "" {
            Provider.displayBook.id = -2
            Provider.displayBook.loc = "你可能被临时禁止登录，请稍后再试"
        }
        
        if json["status"] == "fail" {
            Provider.displayBook.id = -2
            Provider.displayBook.loc = json["message"].stringValue
        }
        
        if json["status"] == "success" {
            spider.history(pageNum: 1, pageSize: 5)
            return
        }
        group.leave()
    }
    
    mutating func getHistoryDelegate(data: AFDataResponse<String>) {
        
        if data.value == "ERROR: Abnormal using detected!!!" {
            spider.token = ""
            spider.login()
            return
        }
        
        let json = JSON(parseJSON: data.value ?? "")
        print(json)
        if json["status"] == "success" {
            Provider.displayBook = CurrentBookEntry()
            json["data"]["reservations"].forEach { (str: String, subJson: JSON) in
                let status = subJson["stat"]
                
                if status == "RESERVE" || status == "CHECK_IN" || status == "AWAY" {
                    Provider.displayBook.id = subJson["id"].intValue
                    Provider.displayBook.displayDate = subJson["date"].stringValue
                    Provider.displayBook.begin = subJson["begin"].stringValue
                    Provider.displayBook.end = subJson["end"].stringValue
                    Provider.displayBook.awayBegin = subJson["awayBegin"].stringValue
                    Provider.displayBook.awayEnd = subJson["awayEnd"].stringValue
                    Provider.displayBook.stat = subJson["stat"].stringValue
                    
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
                        
                        Provider.displayBook.seatNum = String(seatNum)
                        Provider.displayBook.loc = rawLoc
                    }
                    else {
                        Provider.displayBook.seatNum = ""
                        Provider.displayBook.loc = rawLoc
                    }
                }
                
                
            }
        }
        group.leave()
    }
    
    func placeholder(in context: Context) -> CurrentBookEntry {
        return CurrentBookEntry(id: 0, seatNum: "---", loc: "-------------", stat: "CHECK_IN", begin: "--:--", end: "--:--")
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (CurrentBookEntry) -> ()) {
//        var entry = CurrentBookEntry()
//        entry.id = -2
//        entry.loc = "信息馆2层东区东自然科学区"
//        entry.seatNum = "049"
//        entry.stat = "CHECK_IN"
//        entry.begin = "14:00"
//        entry.end = "22:30"
        
        //设置爬虫委托
        spider.historyDelegate = self
        spider.loginDelegate = self
        
        group.enter()
        dispatchQueue.async {
            self.spider.history(pageNum: 1, pageSize: 5)
        }
        
        group.notify(queue: dispatchQueue) {
            completion(Provider.displayBook)
        }
    }
 
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        //设置爬虫委托
        spider.historyDelegate = self
        spider.loginDelegate = self
        
        //这次后的更新日期
        
        print("upate")
//        let currentDate = Date()
//        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)!
        
//        let displayBook = CurrentBookEntry()
//        var arr = [displayBook, displayBook]
//        arr[0].date = currentDate
//        arr[1].date = nextUpdateDate
//
//        arr[0].id = 0
//        arr[0].loc = Date().milliStamp
//
//        let timeline = Timeline(entries: arr, policy: .atEnd)
//        print("updateData")
//        completion(timeline)
        
        group.enter()
        dispatchQueue.async {
            self.spider.history(pageNum: 1, pageSize: 5)
        }

        group.notify(queue: dispatchQueue) {
            let currentDate = Date()
            let nextUpdateDate: Date?
            
            switch configuration.interval {
            case .interval5m:
                nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
            case .interval10m, .unknown:
                nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 10, to: currentDate)!
            case .interval30m:
                nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate)!
            case .interval1hour:
                nextUpdateDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
            case .interval2hour:
                nextUpdateDate = Calendar.current.date(byAdding: .hour, value: 2, to: currentDate)!
            }
            
           

            var arr: [CurrentBookEntry] = [Provider.displayBook, Provider.displayBook]
            
            arr[0].date = currentDate
            arr[1].date = nextUpdateDate!

            let timeline = Timeline(entries: arr, policy: .atEnd)
            print("updateData")
            completion(timeline)
        }
    }
}


struct CurrentBookEntry: TimelineEntry {
    var date: Date = Date()
    var id: Int = -1
    var displayDate: String = ""
    var seatNum: String = ""
    var loc: String = ""
    var stat: String = ""
    var bookDate: String = ""
    var begin: String = ""
    var end: String = ""
    var awayBegin: String = ""
    var awayEnd: String = ""
    var configuration: ConfigurationIntent = ConfigurationIntent()
}

struct LibraryWidgetEntryView : View {
    var entry: Provider.Entry

    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        Group {
            if widgetFamily == .systemSmall {
                if entry.id != -1 && entry.id != -2 {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(entry.seatNum)
                                .font(.largeTitle)
                            Group {
                                if entry.stat == "RESERVE" {
                                    Text("已预约")
                                        .foregroundColor(.blue)
                                        .font(.caption)
                                }
                                else if entry.stat == "CHECK_IN" {
                                    Text("已入馆")
                                        .foregroundColor(.green)
                                        .font(.caption)
                                }
                                else if entry.stat == "AWAY" {
                                    Text("暂离于\(entry.awayBegin)")
                                        .foregroundColor(.orange)
                                        .font(.caption)
                                }
                            }
                            
                            Text(entry.loc)
                                .font(.caption)
                                .padding(.top, 0.01)
                            Text("\(entry.begin)-\(entry.end)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .padding(.top, 0.01)
                        }.padding()
                        Spacer()
                    }
                }
                else if entry.id == -2 {
                    Text(entry.loc)
                }
                else {
                    Text("暂无有效预约")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            else if widgetFamily == .systemMedium {
                if entry.id != -1 && entry.id != -2 {
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                            VStack {
                                Spacer()
                                Text(entry.seatNum)
                                    .font(.system(size: 50))
                                Group {
                                    if entry.stat == "RESERVE" {
                                        Text("已预约")
                                            .foregroundColor(.blue)
                                            .font(.caption)
                                    }
                                    else if entry.stat == "CHECK_IN" {
                                        Text("已入馆")
                                            .foregroundColor(.green)
                                            .font(.caption)
                                    }
                                    else if entry.stat == "AWAY" {
                                        Text("暂离于\(entry.awayBegin)")
                                            .foregroundColor(.orange)
                                            .font(.caption)
                                    }
                                }
                                Spacer()
                            }.frame(width: geometry.size.width * 0.5)
                            VStack(alignment: .leading) {
                                Text(entry.loc)
                                    .font(.caption)
                                    .padding(.top, 0.01)
                                Text("\(entry.begin)-\(entry.end)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 0.01)
                            }
                            
                            .frame(width: geometry.size.width * 0.45)
                            Spacer()
                            
                        }
                    }
                }
                else if entry.id == -2 {
                    Text(entry.loc)
                }
                else {
                    Text("暂无有效预约")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .widgetURL(URL(string: "hanmu://library"))
    }
}

@main
struct LibraryWidget: Widget {
    let kind: String = "LibraryWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            LibraryWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("图书馆预约")
        .description("方便查看你的预约信息")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct LibraryWidget_Previews: PreviewProvider {
    static var previews: some View {
//        LibraryWidgetEntryView(entry: CurrentBookEntry())
//            .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        LibraryWidgetEntryView(entry: CurrentBookEntry())
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

extension Date {
    
    /// 获取当前 秒级 时间戳 - 10位
    var timeStamp : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        return "\(timeStamp)"
    }
    
    /// 获取当前 毫秒级 时间戳 - 13位
    var milliStamp : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let millisecond = CLongLong(round(timeInterval*1000))
        return "\(millisecond)"
    }
}
