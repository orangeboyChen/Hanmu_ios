//
//  RebookView.swift
//  Hanmu
//
//  Created by orangeboy on 2021/6/19.
//

import SwiftUI
import WidgetKit
import Alamofire
import SwiftyJSON

struct RebookView: View, BookControlDelegate, RebookDelegate {
    mutating func changeTimeDelegate(status: LibrarySpider.RebookStatus, data: String) {
        isRebookLoading = false
        switch status {
        case .success:
            BannerService.getInstance().showBanner(title: "操作成功", content: "", type: .Success)
            isRebookViewActive = false
        case .bookError:
            BannerService.getInstance().showBanner(title: "操作失败。座位已释放，请重新预约。", content: data, type: .Error)

        default:
            BannerService.getInstance().showBanner(title: "操作失败", content: data, type: .Error)
        }
    }
    
    mutating func cancelDelegate(data: AFDataResponse<Any>) {
        let json = JSON(data.data)
        print(json)
        
        withAnimation {
            isCancelLoading = false
            
            if json["status"] == "success" {
                currentBook.clear()
                BannerService.getInstance().showBanner(title: "操作成功", content: "", type: .Success)
                WidgetCenter.shared.reloadTimelines(ofKind: "LibraryWidget")
                isRebookViewActive = false
            }
            else {
                BannerService.getInstance().showBanner(title: "操作失败", content: json["message"].stringValue, type: .Error)
            
            }
        }

    }
    
    mutating func stopDelegate(data: AFDataResponse<Any>) {
        let json = JSON(data.data)
        withAnimation {
            isCancelLoading = false
            
            if json["status"] == "success" {
                BannerService.getInstance().showBanner(title: "已释放座位", content: "", type: .Success)
                currentBook.clear()
                isRebookViewActive = false
            }
            else {
                BannerService.getInstance().showBanner(title: "操作失败", content: json["message"].stringValue, type: .Error)
            }
        }
    }
    
    @State var fromTime: Date = Date()
    @State var toTime: Date = Date()
    
    @State var currentBook: Book
    @State var currentFromTime: Date = Date()
    @State var currentToTime: Date = Date()
    
    @State var isCancelLoading = false
    
    @State var isRebookLoading = false
    

    
    @Binding var isRebookViewActive: Bool
    
    let spider = LibrarySpider.getInstance()
    
    func string2Date(_ string:String, dateFormat:String = "HH:mm") -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale.init(identifier: "zh_CN")
        formatter.dateFormat = dateFormat
        let date = formatter.date(from: string)
        return date!
    }
    
    var body: some View {
        Form {
            Section {
                HStack{
                    VStack(alignment: .leading){
                        Text(currentBook.loc ?? ""
                        )
                            .font(.headline)
                        Text("\(currentBook.date!) \(currentBook.begin!) - \(currentBook.end!)")
                        if currentBook.stat == "AWAY" {
                            Text("离开于\(currentBook.awayBegin!)")
                                .foregroundColor(.orange)
                        }
                        
                    }
                    Spacer()
                    Group {
                        if currentBook.stat == "RESERVE" {
                            Text("已预约")
                                .foregroundColor(.blue)
                        }
                        else if currentBook.stat == "CHECK_IN" {
                            Text("已入馆")
                                .foregroundColor(.green)
                        }
                        else if currentBook.stat == "AWAY" {
                            Text("已暂离")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    
                }
                .padding(.vertical)
            }
            
            Section {
                HStack {
                    Text("开始时间")
                    MyDatePicker(selection: $fromTime, minuteInterval: 30, displayedComponents: .hourAndMinute, isFrom: true, parent: self, currentFromTime: $currentFromTime, currentToTime: $currentToTime, fromTime: $fromTime, toTime: $toTime)
                }
                HStack {
                    Text("结束时间")
                    MyDatePicker(selection: $toTime, minuteInterval: 30, displayedComponents: .hourAndMinute, isFrom: false, parent: self, currentFromTime: $currentFromTime, currentToTime: $currentToTime, fromTime: $fromTime, toTime: $toTime)
                }
                Button(action: {
                    let calendar = Calendar.current
                    let startTime = calendar.component(.hour, from: fromTime) * 60 + calendar.component(.minute, from: fromTime)
                    
                    let endTime = calendar.component(.hour, from: toTime) * 60 + calendar.component(.minute, from: toTime)
                    isRebookLoading = true
                    spider.changeBookTime(t: "1", t2: "2", startTime: String(startTime), endTime: String(endTime), date: currentBook.date!)
                }, label: {
                    HStack {
                        Text("修改时间")
                            .foregroundColor((currentFromTime == fromTime && currentToTime == toTime) || (isCancelLoading || isRebookLoading) ? .gray : .blue)
                        Spacer()
                        if isRebookLoading {
                            ProgressView()
                        }
                    }

                }).disabled((currentFromTime == fromTime && currentToTime == toTime) || (isCancelLoading || isRebookLoading))

                    
            }

            
            Section {
                Button(action: {
                    isCancelLoading = true
                    
                    if currentBook.stat == "RESERVE" {
                        spider.cancel(id: String(self.currentBook.id))
                    }
                    
                    if currentBook.stat == "CHECK_IN" || currentBook.stat == "AWAY" {
                        spider.stop()
                    }
                    
                    WidgetCenter.shared.reloadTimelines(ofKind: "LibraryWidget")
                }, label: {
                    HStack {
                        if currentBook.stat == "RESERVE" {
                            Text("取消预约")
                                .foregroundColor(isCancelLoading || isRebookLoading ? .gray : .red)
                        }
                        else if currentBook.stat == "CHECK_IN" {
                            Text("结束使用")
                                .foregroundColor(isCancelLoading || isRebookLoading ? .gray : .blue)
                        }
                        else if currentBook.stat == "AWAY" {
                            Text("结束使用")
                                .foregroundColor(isCancelLoading || isRebookLoading ? .gray : .blue)
                        }

                        Spacer()
                        if isCancelLoading {
                            ProgressView()
                        }
                    }
                }).disabled(isCancelLoading || isRebookLoading)
                
                
            }
        }
        .navigationTitle("变更预约")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: {
            spider.changeTimeDelegate = self
            
            currentFromTime = string2Date(currentBook.begin!)
            currentToTime = string2Date(currentBook.end!)
            
            fromTime = currentFromTime
            toTime = currentToTime
            
            print("time!! \(fromTime) \(toTime)")

        })
        
        }
    }
    
    struct MyDatePicker: UIViewRepresentable {
        @Binding var selection: Date
        let minuteInterval: Int
        let displayedComponents: DatePickerComponents
        
        var isFrom: Bool
        var parent: RebookView
        
        @Binding var currentFromTime: Date
        @Binding var currentToTime: Date
        @Binding var fromTime: Date
        @Binding var toTime: Date


        func makeCoordinator() -> Coordinator {
            return Coordinator(self)
        }

        func makeUIView(context: UIViewRepresentableContext<MyDatePicker>) -> UIDatePicker {
            let picker = UIDatePicker()
            // listen to changes coming from the date picker, and use them to update the state variable
            picker.addTarget(context.coordinator, action: #selector(Coordinator.dateChanged), for: .valueChanged)
            return picker
        }

        func updateUIView(_ picker: UIDatePicker, context: UIViewRepresentableContext<MyDatePicker>) {
            picker.minuteInterval = minuteInterval
            picker.date = selection
            
            picker.locale = Locale(identifier: "en_GB")
            picker.timeZone = TimeZone.current
            picker.datePickerMode = .time
            
            if isFrom {
                picker.minimumDate = currentFromTime
                picker.maximumDate = toTime.addingTimeInterval(TimeInterval(-30 * 60))
            }
            else {
                picker.minimumDate = currentFromTime.addingTimeInterval(TimeInterval(30 * 60))
                picker.maximumDate = currentToTime
            }

        }

        class Coordinator {
            let datePicker: MyDatePicker
            init(_ datePicker: MyDatePicker) {
                self.datePicker = datePicker

            }

            @objc func dateChanged(_ sender: UIDatePicker) {
                datePicker.selection = sender.date
            }
        }
    }



struct RebookView_Previews: PreviewProvider {
    static var previews: some View {
        RebookView(currentBook: Book(), isRebookViewActive: .constant(true))
    }
}
