//
//  LibraryView.swift
//  Hanmu
//
//  Created by orangeboy on 2021/3/13.
//

import SwiftUI
import Alamofire
import SwiftyJSON

struct LibraryView: View, HistoryDelegate, BookControlDelegate {

    var spider: LibrarySpider = LibrarySpider.getInstance()
    
    @StateObject var displayBook: Book = Book()
    
    @State var isDisplayBookLoading: Bool = false
    @State var isCancelOrStopLoading: Bool = false
    
    @State var alertInfo: AlertInfo?
    
    @State var isBookViewActive: Bool = false

    @AppStorage("libraryToken") var token: String = ""
    

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
                        Text("当前预约")
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
                                            .foregroundColor(.blue)
                                    }
                                    else if displayBook.stat == "AWAY" {
                                        Text("已暂离")
                                            .foregroundColor(.blue)
                                    }
                                }
                                
                                
                            }
                            .padding(.vertical)
                            Group {
                                if displayBook.stat == "RESERVE" {
                                    Button(action: {
                                        isCancelOrStopLoading = true
                                        spider.cancel(id: String(self.displayBook.id))
                                    }, label: {
                                        HStack {
                                            Text("取消预约")
                                            
                                            
                                            Spacer()
                                            if isCancelOrStopLoading {
                                                ProgressView()
                                            }
                                        }
                                    }).disabled(isCancelOrStopLoading)
                                    .foregroundColor(isCancelOrStopLoading ? .gray : .red)
                                }
                                else if displayBook.stat == "CHECK_IN" {
                                    Button(action: {
                                        
                                        spider.stop()
                                    }, label: {
                                        HStack {
                                            Text("结束使用")
                                            
                                            Spacer()
                                            if isCancelOrStopLoading {
                                                ProgressView()
                                            }
                                        }
                                        
                                    })
                                    .disabled(isCancelOrStopLoading)
                                }
                                else if displayBook.stat == "AWAY" {
                                    Button(action: {
                                        isCancelOrStopLoading = true
                                        spider.stop()
                                    }, label: {
                                        HStack {
                                            Text("结束使用")
                                            
                                            
                                            Spacer()
                                            if isCancelOrStopLoading {
                                                ProgressView()
                                            }
                                        }
                                    }).disabled(isCancelOrStopLoading)
                                    
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
                    NavigationLink(destination: LibraryHistory()) {
                        Text("历史预约记录")
                    }
                }
                
                Section {
                    NavigationLink(
                        destination: MyLibraryInfoView()) {
                        Text("个人信息")
                    }
                }
            }
            else {
                NavigationLink(destination: LibraryAccountView()) {
                    Text("添加登录信息")
                }
            }
            


            


        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear(perform: {
            spider.historyDelegate = self
            spider.bookControlDelegate = self
            
            if spider.token != "" {
                withAnimation {
                    isDisplayBookLoading = true
                }

                spider.history(pageNum: 1, pageSize: 5)
            }
            
        })
        .alert(item: $alertInfo) { info in
            Alert(title: Text(info.title), message: Text(info.info), dismissButton: .none)
        }
        
    }
    
    mutating func getHistoryDelegate(data: AFDataResponse<Any>) {

        withAnimation {
            isDisplayBookLoading = false
            
            
            let json = JSON(data.data)
            print(json)
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
//                alertInfo = AlertInfo(title: "已取消预约", info: "")
                displayBook.clear()
            }
            else {
                alertInfo = AlertInfo(title: "操作失败", info: json["message"].stringValue)
            }
        }

    }
    
    mutating func stopDelegate(data: AFDataResponse<Any>) {
        let json = JSON(data.data)
        print(json)
        withAnimation {
            isCancelOrStopLoading = false
            
            if json["status"] == "success" {
                alertInfo = AlertInfo(title: "已释放座位", info: "")
                displayBook.clear()
            }
            else {
                alertInfo = AlertInfo(title: "操作失败", info: json["message"].stringValue)
            }
        }
        
    }
}

struct Library_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}
