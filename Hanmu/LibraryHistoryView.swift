//
//  LibraryHistory.swift
//  Hanmu
//
//  Created by orangeboy on 2021/3/15.
//

import SwiftUI
import Alamofire
import SwiftyJSON

struct LibraryHistory: View, HistoryPageDelegate {
    
    
    @State var bookDictionary: Dictionary<String, [Book]> = [:]
    @State var books: [Book] = []
    
    @State var pageNum: Int = 1
    @State var pageSize: Int = 12
    @State var initPageSize: Int = 12
    @State var isHistoryLoading: Bool = false
    @State var isMoreHistory: Bool = true
    
    @Binding var isActive: Bool

    
    var spider: LibrarySpider = LibrarySpider.getInstance()
    var body: some View {
        Form {
            ForEach(Array(bookDictionary.keys).sorted(by: { (a: String, b: String) -> Bool in
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
                                                      
                                                      }), id: \.self){ key in
                Section(header: Text(key)) {
                    ForEach(bookDictionary[key]!.sorted(by: {$0.id > $1.id}), id: \.self.id) { book in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(book.loc ?? "")
                                    .font(.headline)
                                Text("\(book.begin ?? "")-\(book.end ?? "")")
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
                                        .foregroundColor(.green)
                                }
                                else if book.stat == "AWAY" {
                                    Text("已暂离")
                                        .foregroundColor(.orange)
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
                        .onAppear(perform: {
                            if book.index > books.count - 6 && !isHistoryLoading && isMoreHistory {
                                isHistoryLoading = true
                                spider.historyPage(pageNum: pageNum, pageSize: pageSize)
                            }
                            
                        })
                    }
                }.animation(.spring())
            }
            
            if isHistoryLoading {
                Section {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }
            
            
        }
        .navigationTitle("历史记录")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: {
            spider.historyPageDelegate = self
            initBookView()
        })
    }
    
    func initBookView() {
        books = []
        bookDictionary = [:]
        isMoreHistory = true
        isHistoryLoading = true
        spider.historyPage(pageNum: pageNum, pageSize: initPageSize)
    }
    
    func setBookIndex() {
        withAnimation {
            books.sort(by: {
                let a = $0.date?.components(separatedBy: " ")[0]
                let b = $1.date?.components(separatedBy: " ")[0]
                
                let aArray = a!.components(separatedBy: "-")
                let bArray = b!.components(separatedBy: "-")
                
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
                        return $0.id > $1.id
                    }
                }
            })
            
            for i in 0..<books.count {
                books[i].index = i
            }
        }
        
    }
    
    mutating func getHistoryDelegate(data: AFDataResponse<Any>) {
        isHistoryLoading = false
        let json = JSON(data.data)
        
        
        if json["status"] == "success" {
            
            if json["data"]["reservations"].arrayValue.count == 0 {
                isMoreHistory = false
            }
            
            let a = json["data"]["reservations"].arrayValue
            
            
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
                let dateString: String = (book.date?.components(separatedBy: " ")[0])!
                if bookDictionary.keys.contains(dateString){
                    bookDictionary[dateString]!.append(book)
                }
                else{
                    bookDictionary[dateString] = [book]
                }

                
            }
            
            setBookIndex()
            
            pageNum += 1
        }
        else {
            BannerService.getInstance().showBanner(title: "获取失败", content: json["message"].stringValue, type: .Error)
            
            if json["message"].stringValue == "系统维护中" {
                isActive = false
            }
            
        }

    }
}

struct LibraryHistory_Previews: PreviewProvider {
    static var previews: some View {
        LibraryHistory(isActive: .constant(true))
    }
}

