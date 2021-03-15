//
//  LibraryHistory.swift
//  Hanmu
//
//  Created by orangeboy on 2021/3/15.
//

import SwiftUI
import Alamofire
import SwiftyJSON

struct LibraryHistory: View, HistoryDelegate {

    @State var isHistoryLoading: Bool = false
    
    @State var books: [Book] = []
    
    @State var alertInfo: AlertInfo?
    
    var spider: LibrarySpider = LibrarySpider.getInstance()
    var body: some View {
        Form {
            Section(header: HStack {
                if isHistoryLoading {
                    ProgressView()
                }
            }) {
                ForEach(books, id: \.self.id){book in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(book.loc ?? "")
                                .font(.headline)
                            Text("\(book.date ?? "") \(book.begin ?? "")-\(book.end ?? "")")
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical)
                        Spacer()
                        Group {
                            if book.stat == "RESERVE" {
                                Text("已预约")
                                    .foregroundColor(.blue)
                            }
                            else if book.stat == "CHECK_IN" {
                                Text("已入馆")
                                    .foregroundColor(.blue)
                            }
                            else if book.stat == "AWAY" {
                                Text("已暂离")
                                    .foregroundColor(.blue)
                            }
                            else if book.stat == "CANCEL" {
                                Text("已取消")
                                    .foregroundColor(.gray)
                            }
                            else if book.stat == "COMPLETE" {
                                Text("已履约")
                                    .foregroundColor(.gray)
                            }
                            else if book.stat == "STOP" {
                                Text("已结束")
                                    .foregroundColor(.gray)
                            }
                            else if book.stat == "MISS" {
                                Text("失约")
                                    .foregroundColor(.red)
                            }
                            else if book.stat == "INCOMPLETE" {
                                Text("早退")
                                    .foregroundColor(.red)
                            }
                            else {
                                Text("未知")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                    }
                }
                }
                

    }
        .navigationBarTitle("历史记录", displayMode: .inline)
        .onAppear(perform: {
            spider.historyDelegate = self
            spider.history(pageNum: 1, pageSize: 9999)
            isHistoryLoading = true
        })
        .alert(item: $alertInfo) { info in
            Alert(title: Text(info.title), message: Text(info.info), dismissButton: .none)
        }
    }
    
    mutating func getHistoryDelegate(data: AFDataResponse<Any>) {
        isHistoryLoading = false
        let json = JSON(data.data)
        print(json)
        
        if json["status"] == "success" {
            withAnimation {
                books = []
                json["data"]["reservations"].forEach { (str: String, subJson: JSON) in
                    let book = Book()
                    book.id = subJson["id"].intValue
                    book.date = subJson["date"].stringValue
                    book.begin = subJson["begin"].stringValue
                    book.end = subJson["end"].stringValue
                    book.awayBegin = subJson["awayBegin"].stringValue
                    book.awayEnd = subJson["awayEnd"].stringValue
                    book.stat = subJson["stat"].stringValue
                    book.loc = subJson["loc"].stringValue
                    books.append(book)
                }
                books.sort(by: {$0.id > $1.id})
            }
        }
        else {
            alertInfo = AlertInfo(title: "获取失败", info: json["message"].stringValue)
        }
    }
}

struct LibraryHistory_Previews: PreviewProvider {
    static var previews: some View {
        LibraryHistory()
    }
}
