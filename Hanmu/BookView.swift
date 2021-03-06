//
//  BookView.swift
//  Hanmu
//
//  Created by orangeboy on 2021/3/13.
//

import SwiftUI
import SwiftyJSON
import Alamofire
import WidgetKit



struct BookView: View, LibrarySpiderDelegate, LoginDelegate {
    @AppStorage("userId", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var userId = ""
    @AppStorage("password", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var password = ""
    
    @AppStorage("lastBookSeatId", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var lastBookSeatId: Int = -1
    
    
    @AppStorage("libraryInfoCache", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var libraryInfoCache = ""
    
    @AppStorage("roomInfoCache", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var roomInfoCache = ""
    
    @State var isNewRefresh: Bool = false

    
    
    var spider: LibrarySpider = LibrarySpider.getInstance()
    
    @State var userName: String = ""
    @State var isCheckedIn: Bool = false
    
    @State var buildings: Dictionary<Int, Building> = [:]
    @State var rooms: Dictionary<Int, Room> = [:]
    @State var buildingCount: Int = 0
    
    //预约需要的信息
    @AppStorage("lastSelectedBuildingId", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var savedBuildingId: Int = -1
    @AppStorage("lastSelectedRoomId", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var savedRoomId: Int = -1

    
    @State var selectBuildingId: Int = -1
    
    @State var selectRoomId: Int = -1
    @State var selectSeatId: Int = -1
    
    @AppStorage("librarySelectFromTime", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var selectFromTime: Int = -1
    @AppStorage("librarySelectToTime", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var selectToTime: Int = -1
    
    
    //显示的座位
    @State var seats: [Seat] = []
    
    
    //显示的座位总数
    @State var displaySeatTotal = 0
    
    //附加条件
    @AppStorage("libraryIsPower", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var isPower: Bool = false
    @AppStorage("libraryIsWindow", store: UserDefaults(suiteName: "group.com.nowcent.hanmu.orangeboy")) var isWindow: Bool = false
    @State var isTomorrow: Bool = false
    @State var isTomorrowSet: Bool = false
    
    
    //加载绑定
    @State var isRoomDetailLoading: Bool = false
    @State var isSeatDetailLoading: Bool = false
    @State var isBuildingInfoLoading: Bool = false
    @State var isBookLoading: Bool = false
    
    //图书馆预约时间数组
    @State var libraryTimes: [LibraryTime] = []
    
    @Binding var isBookViewActive: Bool
    
    var body: some View {
        Form{
            if spider.token != "" {
                Section(header: HStack {
                    Text("预约地点")
                    
                })
                {
                    if isBuildingInfoLoading {
                        HStack {
                            Text("场馆")
                            Spacer()
                            ProgressView()
                        }
                    }
                    else {
                        Picker(selection: $selectBuildingId, label: Text("场馆")) {
                            ForEach(Array(buildings.keys), id: \.self) { key in
                                Text(buildings[key]!.name).tag(key)
                            }
                            
                        }
                        .disabled(isRoomDetailLoading || isBuildingInfoLoading)
                        .onChange(of: selectBuildingId, perform: { value in
                            if(savedBuildingId != selectBuildingId) {
                                selectRoomId = -1
                                selectSeatId = -1
                                seats = []
                                displaySeatTotal = 0
                                
                                isRoomDetailLoading = true
                                
                                savedBuildingId = selectBuildingId
                                savedRoomId = -1
                                
                                spider.getRoomDetail(libraryId: String(selectBuildingId))
                            }

                        })
                        
                    }
                    
                    
                    if isRoomDetailLoading{
                        HStack {
                            Text("房间")
                            Spacer()
                            ProgressView()
                        }
                    }
                    else{
                        Picker(selection: $selectRoomId, label: Text("房间")
                        ) {
                            if buildings.keys.contains(selectBuildingId) {
                                let targetRooms = buildings[selectBuildingId]!.rooms
                                var targetRoomKeyArray = Array(targetRooms.keys)
                                let _ = targetRoomKeyArray.sort(by: {targetRooms[$0]!.floor < targetRooms[$1]!.floor})
                                
                                ForEach(targetRoomKeyArray, id: \.self) { key in
                                    let room: Room = targetRooms[key]!
                                    let freeSeatInfoStr = String(room.free) + "/" + String(room.total)
                                    VStack(alignment: .leading) {
                                        Text(room.name)
                                        HStack {
                                            Text(String(room.floor) + "F")
                                                .foregroundColor(.gray)
                                            if room.free != -1 && isNewRefresh {
                                                Group {
                                                    let color = room.free < 15 && room.free > 5 ? Color.orange : (room.free >= 15 ? Color.green : Color.red)
                                                    
                                                    
                                                    Text(freeSeatInfoStr).foregroundColor(color).padding(.leading, 1.0)
                                                }
                                                
                                            }
                                            
                                            
                                        }
                                        
                                    }
                                    .tag(room.id)
                                }
                            }
                        }
                        .disabled(selectBuildingId == -1)
                        .onChange(of: selectRoomId, perform: { value in
                            savedRoomId = selectRoomId
                            selectSeatId = -1
                            isSeatDetailLoading = true
                            
                            if selectFromTime != -1 && selectToTime != -1 {
                                spider.searchSeatByTime(buildingId: String(selectBuildingId), roomId: String(selectRoomId), dateStr: getDateString(), startTime: String(selectFromTime), endTime: String(selectToTime)
                                )
                            }
                            else {
                                spider.getSeatDetail(roomId: String(selectRoomId), dateStr: getDateString())
                            }
                            
                        })
                    }
                    
                    
                }
                
                Section(header: Text("附加条件"))
                {
                    Toggle(isOn: $isPower) {
                        Text("电源")
                    }.onChange(of: isPower) { newIsPower in
                        var total = 0
                        
                        seats.forEach { seat in
                            if (seat.isPower || !newIsPower) && (seat.isWindow || !isWindow) {
                                total += 1
                            }
                        }
                        withAnimation {
                            selectSeatId = -1
                            displaySeatTotal = total
                        }
                        
                        
                    }
                    Toggle(isOn: $isWindow) {
                        Text("阳光")
                    }.onChange(of: isWindow) { newIsWindow in
                        var total = 0
                        
                        seats.forEach { seat in
                            if (seat.isPower || !isPower) && (seat.isWindow || !newIsWindow) {
                                total += 1
                            }
                        }
                        withAnimation {
                            selectSeatId = -1
                            displaySeatTotal = total
                        }
                    }
                }
                
                Section(header: Text("预约时间")){
                    Toggle(isOn: $isTomorrow) {
                        Text("预约明天")
                    }
                    .onChange(of: isTomorrow, perform: { newValue in
                        if(isTomorrowSet) {
                            
                            print(newValue)
                            withAnimation {
    //                            isSeatDetailLoading = true
                                isRoomDetailLoading = true
                            }
                            spider.getRoomDetail(libraryId: String(selectBuildingId))
                            if selectFromTime != -1 && selectToTime != -1 {
                                spider.searchSeatByTime(buildingId: String(selectBuildingId), roomId: String(selectRoomId), dateStr: getDateString(isTomorrow: newValue), startTime: String(selectFromTime), endTime: String(selectToTime)
                                )
                            }
                            else {
                                spider.getSeatDetail(roomId: String(selectRoomId), dateStr: getDateString(isTomorrow: newValue))
                            }
                        }
                        isTomorrowSet = true

                    })
                    
                    Picker(selection: $selectFromTime, label: Text("开始时间")) {
                        let calendar:Calendar = Calendar.current;
                        let now = Date()
                        let hour = calendar.component(.hour, from: now)
                        let minute = calendar.component(.minute, from: now)
                        ForEach(libraryTimes, id: \.self.time) { time in
                            if (time.time >= (16 * 30)) && (time.time <= (44 * 30)) && ((time.time > hour * 60 + minute) || isTomorrow ){
                                Text(time.displayTime)
                                    .tag(time.time)
                            }
                            
                        }
                    }.onChange(of: selectFromTime, perform: { newFromTime in
                        if selectToTime != -1 && newFromTime != -1 {
                            if selectToTime <= newFromTime {
                                withAnimation {
                                    selectToTime = -1
                                }
                            }
                            else {
                                spider.searchSeatByTime(buildingId: String(selectBuildingId), roomId: String(selectRoomId), dateStr: getDateString(), startTime: String(selectFromTime), endTime: String(selectToTime)
                                )
                                isSeatDetailLoading = true
                            }
                        }
                        
                    })
                    
                    Picker(selection: $selectToTime, label: Text("结束时间")) {
                        let calendar:Calendar = Calendar.current;
                        let now = Date()
                        let hour = calendar.component(.hour, from: now)
                        let minute = calendar.component(.minute, from: now)
                        ForEach(libraryTimes, id: \.self.time) { time in
                            if selectFromTime == -1 || (selectFromTime != -1 && time.time > selectFromTime) && (time.time >= (17 * 30)) &&  (time.time <= (45 * 30)) && ((time.time > hour * 60 + minute) || isTomorrow){
                                Text(time.displayTime)
                                    .tag(time.time)
                            }
                            
                        }
                    }.onChange(of: selectToTime, perform: { newToTime in
                        if selectFromTime != -1 && newToTime != -1 {
                            if selectFromTime >= newToTime {
                                withAnimation {
                                    selectFromTime = -1
                                }
                            }
                            else {
                                spider.searchSeatByTime(buildingId: String(selectBuildingId), roomId: String(selectRoomId), dateStr: getDateString(), startTime: String(selectFromTime), endTime: String(selectToTime)
                                )
                                isSeatDetailLoading = true
                            }
                        }
                    })
                }
                
                Section{
                    if isSeatDetailLoading {
                        HStack {
                            Text("座位")
                            Spacer()
                            ProgressView()
                        }
                    }
                    else {
                        Picker(selection: $selectSeatId, label: Text("座位 \(displaySeatTotal)")) {
                            
                            ForEach(seats, id: \.self.id) { seat in
                                
                                if !((isPower && !seat.isPower) || (isWindow && !seat.isWindow)) {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text(seat.name)
                                            if seat.isComputer {
                                                Image(systemName: "desktopcomputer")
                                                    .foregroundColor(.blue)
                                            }
                                            
                                            if seat.isPower {
                                                Image(systemName: "battery.100.bolt")
                                                    .foregroundColor(.green)
                                            }
                                            
                                            if seat.isWindow {
                                                Image(systemName: "sun.max")
                                                    .foregroundColor(.orange)
                                            }
                                        }
                                    }
                                    .tag(seat.id)
                                }
                            }
                        }
                        .disabled(displaySeatTotal == 0 || isRoomDetailLoading)
                    }
                    
                }
                
                Section{
                    Button(action: {
                        WidgetCenter.shared.reloadTimelines(ofKind: "LibraryWidget")
                        
                        let calendar:Calendar = Calendar.current;
                        let now = Date()
                        let hour = calendar.component(.hour, from: now)
                        let minute = calendar.component(.minute, from: now)
                        let currentTime = hour * 60 + minute
                        
                        if (selectFromTime > currentTime && selectToTime > currentTime) || (isTomorrow && selectFromTime != -1 && selectToTime != -1) {
                            isBookLoading = true
                            spider.book(t: "1", t2: "2", startTime: String(selectFromTime), endTime: String(selectToTime), seat: String(selectSeatId), date: getDateString(), userId: userId, password: password)
                        }
                        else {
                            BannerService.getInstance().showBanner(title: "预约失败", content: "请重新选择时间", type: .Error)
                        }

                    }, label: {
                        HStack {
                            Text("预约")
                            if isBookLoading {
                                Spacer()
                                ProgressView()
                            }
                        }
                        
                    }).disabled(selectFromTime == -1 || selectToTime == -1 || selectSeatId == -1 || isBookLoading)
                }
            }
            else {
                NavigationLink(destination: LibraryAccountView()) {
                    Text("添加登录信息")
                }
            }
        }
        .navigationTitle("预约")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: {
            WidgetCenter.shared.reloadTimelines(ofKind: "LibraryWidget")
            initLibraryTime(from: 0, to: 48, interval: 30)
            spider.delegate = self
            
            let calendar = Calendar.current
            let now = Date()
            let hour = calendar.component(.hour, from: now)
            
            if(!isTomorrowSet) {
                isTomorrow = hour < 8 || hour >= 22
            }
            
            
            
            if userId != "" && password != "" && spider.token == "" {
                spider.login(userId: userId, password: password)
            }
            
            if selectBuildingId == -1 {
                selectBuildingId = savedBuildingId
                if libraryInfoCache != "" {
                    let json = JSON.init(parseJSON: libraryInfoCache)
                    if json["status"] == "success" {

                        buildings = [:]
                        buildingCount = 0
                        withAnimation {
                            
                            
                            json["data"]["buildings"].forEach { (str: String, subJson: JSON) in
                                let building = Building(id: subJson[0].intValue, name: subJson[1].stringValue)
                                buildings[subJson[0].int!] = building
                            }
                            
                            json["data"]["rooms"].forEach { (str: String, subJson: JSON) in
                                let room = Room(id: subJson[0].intValue, buildingId: subJson[2].intValue, name: subJson[1].stringValue, floor: subJson[3].intValue)
                                buildings[subJson[2].intValue]?.rooms[subJson[0].intValue] = room
                                rooms[subJson[0].int!] = room
                            }
                            
                            buildingCount = buildings.count
                            print(buildingCount)
                        }
                        
                    }
                }
                else {
                    withAnimation {
                        isBuildingInfoLoading = true
                    }
                    spider.getLibraryInfo()
                }

            }
            
            if selectRoomId == -1 && (selectBuildingId != -1 || savedBuildingId != -1) {
                selectRoomId = savedRoomId
                
                if roomInfoCache != "" {
                    let json = JSON.init(parseJSON: roomInfoCache)
                    if json["status"] == "success" {
                        roomInfoCache = json.rawString()!
                        print("appear room \(roomInfoCache)")
                        json["data"].forEach { (str: String, subJson: JSON) in
                            let roomId: Int = subJson["roomId"].intValue
                            if !rooms.keys.contains(subJson["roomId"].intValue){
                                rooms[roomId] = Room(id: roomId, buildingId: selectBuildingId, name: subJson["room"].stringValue, floor: subJson["floor"].intValue)
                                buildings[selectBuildingId]?.rooms[roomId] = rooms[roomId]
                            }
                            rooms[roomId]?.free = subJson["free"].intValue
                            rooms[roomId]?.total = subJson["totalSeats"].intValue
                        }
                    }
                }
                else {
                    withAnimation {
                        isRoomDetailLoading = true
                    }
                    spider.getRoomDetail(libraryId: String(selectBuildingId))
                }

            }
            
            
            
            
            print(spider.token)
            
            
            
            
        })
        .navigationBarItems(trailing:
                                HStack {
                                    if spider.token != "" {
                                        if !isRoomDetailLoading {
                                            Button(action: {
//                                                spider.getLibraryInfo()
//                                                spider.getRoomDetail(libraryId: String(savedBuildingId))
                                                
                                                updateSeatInfo()
                                            }, label: {
                                                Text("更新座位信息")
                                            }
                                            )
                                                .disabled(selectBuildingId == -1)
                                        }
                                        else {
                                            ProgressView()
                                        }

                                    }
                                })
    }
    
    func getDateString(isTomorrow: Bool) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        
        var date: Date = Date()
        if isTomorrow {
            date.addTimeInterval(24 * 60 * 60)
        }
        let str = formatter.string(from: date)
        print(str)
        return str
    }
    
    func getDateString() -> String {
        let  formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        
        var date: Date = Date()
        if isTomorrow {
            date.addTimeInterval(24 * 60 * 60)
        }
        let str = formatter.string(from: date)
        print(str)
        return str
    }
    
    func loginDelegate(data: AFDataResponse<Any>) {
        let json = JSON(data.data)
        print(json)
        
        if json["status"].string ?? "fail" != "success" {
            BannerService.getInstance().showBanner(title: "登录失败", content: json["message"].stringValue, type: .Error)
            return
        }
        spider.getUserInfo()
        spider.getLibraryInfo()
    }
    
    mutating func getLibraryInfoDelegate(data: AFDataResponse<Any>) {
        withAnimation {
            isBuildingInfoLoading = false
        }
        
        let json = JSON(data.data)
        print(isBuildingInfoLoading)
        
        if json["status"] == "success" {
            isNewRefresh = true
            libraryInfoCache = json.rawString()!
            buildings = [:]
            buildingCount = 0
            withAnimation {
                
                
                json["data"]["buildings"].forEach { (str: String, subJson: JSON) in
                    let building = Building(id: subJson[0].intValue, name: subJson[1].stringValue)
                    buildings[subJson[0].int!] = building
                }
                
                json["data"]["rooms"].forEach { (str: String, subJson: JSON) in
                    let room = Room(id: subJson[0].intValue, buildingId: subJson[2].intValue, name: subJson[1].stringValue, floor: subJson[3].intValue)
                    buildings[subJson[2].intValue]?.rooms[subJson[0].intValue] = room
                    rooms[subJson[0].int!] = room
                }
                
                buildingCount = buildings.count
                print(buildingCount)
            }
            
        }
        else{
            BannerService.getInstance().showBanner(title: "获取图书馆信息失败", content: json["message"].stringValue, type: .Error)
            
            if json["message"].stringValue == "系统维护中" {
                isBookViewActive = false
            }
        }
        
        
        
    }
    
    func getRoomDetailDelegate(data: AFDataResponse<String>) {
        withAnimation {
            isRoomDetailLoading = false
        }
        
        let json = JSON(data.data)
        print(json)
        if json["status"] == "success" {
            isNewRefresh = true
            roomInfoCache = json.rawString()!
            json["data"].forEach { (str: String, subJson: JSON) in
                let roomId: Int = subJson["roomId"].intValue
                if !rooms.keys.contains(subJson["roomId"].intValue){
                    rooms[roomId] = Room(id: roomId, buildingId: selectBuildingId, name: subJson["room"].stringValue, floor: subJson["floor"].intValue)
                    buildings[selectBuildingId]?.rooms[roomId] = rooms[roomId]
                }
                rooms[roomId]?.free = subJson["free"].intValue
                rooms[roomId]?.total = subJson["totalSeats"].intValue
            }
        }
        else {
            BannerService.getInstance().showBanner(title: "获取房间信息失败", content: json["message"].stringValue, type: .Error)
        }
        
    }
    
    func getIsValidTokenDelegate(data: AFDataResponse<Any>) {
        
    }
    
    func getSeatDetailDelegate(data: AFDataResponse<Any>) {
        withAnimation {
            isSeatDetailLoading = false
        }
        
        let json = JSON(data.data)
        print(json)
        if json["status"] == "success" {
            self.seats = []
            displaySeatTotal = 0
            json["data"]["layout"].forEach { (key: String, subJson: JSON) in
                if subJson["type"] == "seat"{
                    seats.append(Seat(id: subJson["id"].intValue, name: subJson["name"].stringValue, isPower: subJson["power"].boolValue, isWindow: subJson["window"].boolValue, isComputer: subJson["computer"].boolValue, isFree: subJson["status"] == "FREE"))
                }
            }
            seats.sort(by: {String($0.name) < String($1.name)})
            
            var total = 0
            seats.forEach { seat in
                if (seat.isPower || !isPower) && (seat.isWindow || !isWindow) {
                    total += 1
                }
            }
            withAnimation {
                selectSeatId = -1
                displaySeatTotal = total
            }
        }
    }
    
    func searchSeatDelegate(data: AFDataResponse<Any>) {
        withAnimation {
            self.isSeatDetailLoading = false
        }
        
        let json = JSON(data.data)
        print(json)
        
        if json["status"].boolValue {
            self.seats = []
            json["data"]["seats"].forEach { (key: String, subJson: JSON) in
                seats.append(Seat(id: subJson["id"].intValue, name: subJson["name"].stringValue, isPower: subJson["power"].boolValue, isWindow: subJson["window"].boolValue, isComputer: subJson["computer"].boolValue, isFree: subJson["status"].stringValue == "FREE"))
            }
            
            seats.sort(by: {String($0.name) < String($1.name)})
            
            var total = 0
            seats.forEach { seat in
                if (seat.isPower || !isPower) && (seat.isWindow || !isWindow) {
                    total += 1
                }
            }
            withAnimation {
                selectSeatId = -1
                displaySeatTotal = total
            }
        }
        else {
            BannerService.getInstance().showBanner(title: "搜索座位信息失败", content: json["message"].stringValue, type: .Error)
        }
        
    }
    
    func bookDelegate(data: AFDataResponse<String>, isFree: Bool) {
        print(data)
        isBookLoading = false
        let responseString = data.value ?? ""
        if responseString.prefix(1) != "{" {
            BannerService.getInstance().showBanner(title: "预约失败", content: responseString, type: .Error)
            return
        }
        
        let json = JSON(data.data)
        
        if json["status"] == "success" {
            BannerService.getInstance().showBanner(title: "预约成功", content: json["message"].stringValue, type: .Success)
            lastBookSeatId = selectSeatId
            self.isBookViewActive = false
        }
        else {
            BannerService.getInstance().showBanner(title: "预约失败", content: json["message"].stringValue, type: .Error)
        }
        
    }
    
    func cancelDelegate(data: AFDataResponse<Any>) {
        
    }
    
    func getHistoryDelegate(data: AFDataResponse<Any>) {
        
    }
    
    func stopDelegate(data: AFDataResponse<Any>) {
        
    }
    
    func updateSeatInfo() {
        withAnimation {
            //                            isSeatDetailLoading = true
            isRoomDetailLoading = true
        }
        spider.getRoomDetail(libraryId: String(selectBuildingId))
        if selectFromTime != -1 && selectToTime != -1 {
            spider.searchSeatByTime(buildingId: String(selectBuildingId), roomId: String(selectRoomId), dateStr: getDateString(isTomorrow: isTomorrow), startTime: String(selectFromTime), endTime: String(selectToTime)
            )
        }
        else {
            spider.getSeatDetail(roomId: String(selectRoomId), dateStr: getDateString(isTomorrow: isTomorrow))
        }
    }
    
    func initLibraryTime(from: Int, to: Int, interval: Int) {
        libraryTimes = []
        for i in from..<to {
            libraryTimes.append(
                LibraryTime(
                    time: 60 * from + i * interval,
                    displayTime: "\(from + i / 2):\(i % 2 == 0 ? "00" : "30")")
            )
        }
        libraryTimes.sort(by: {$0.time < $1.time})
        
    }
}

struct Book_Previews: PreviewProvider {
    static var previews: some View {
        BookView(isBookViewActive: .constant(true))
    }
}














