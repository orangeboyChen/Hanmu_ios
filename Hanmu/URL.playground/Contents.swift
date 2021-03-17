import UIKit

var str = "Hello, playground"

/**
 ba6ae77b6a044958ad190859237ad7ca
 GET /api/6c82de5b4e794beab24119f0cc254f1e/QM_Users/Login?wxCode=021Y2A1w3m8QZV2IfE0w3pkiup1Y2A1M&IMEI=CE93E4FC-7637-4D69-A778-440FB1E3FC19 HTTP/1.1
 
 {
 "Success": true,
 "Data": {
 "Token": "10001e245ab14834b04fa70ca4d3773a",
 "UserId": 688078,
 "IMEICode": "5801a078a9ef43c395901806c51a729b",
 "AndroidVer": 2.1,
 "AppleVer": 1.24,
 "WinVer": 1.0
 }
 }
 
 GET /api/10001e245ab14834b04fa70ca4d3773a/QM_Users/GS HTTP/1.1
 {
 "Success": true,
 "Data": {
 "User": {
 "UserID": 688078,
 "NickName": "陈恩瀚",
 "UserName": "2019302110194",
 "Sex": "男",
 "Province": null,
 "City": null,
 "Country": null,
 "HeadImgUrl": "",
 "Mobile": null,
 "MobileVerifyCode": null,
 "IsMoblileVerify": "0",
 "Weights": 0.0,
 "BMI": 0.0,
 "Heights": 0.0,
 "Birthday": "0001-01-01 00:00:00",
 "OldYears": 0,
 "IsInfoOk": "0",
 "WXNickName": null,
 "WXSex": null,
 "IsStationOpen": "0",
 "IsBgMusic": "1",
 "IsReciveMsg": "1",
 "IsSchoolMode": "1",
 "Level_Lengh": 0,
 "Level_Lengh_Date": "2015-01-01 00:00:00",
 "Days_Start": 0,
 "Days_Start_Date": "2015-01-01 00:00:00"
 },
 "SchoolRun": {
 "Sex": "男",
 "SchoolId": "whdx",
 "SchoolName": "武汉大学",
 "MinSpeed": 1.60,
 "MaxSpeed": 5.5,
 "Lengths": 2000,
 "IsNeedPhoto": "0",
 "IsShowAd": 0
 }
 }
 }
 
 
 GET /api/10001e245ab14834b04fa70ca4d3773a/QM_Users/GetGongGao?SchoolId=whdx HTTP/1.1
 {
 "Success": true,
 "Data": null
 }
 
 GET /api/10001e245ab14834b04fa70ca4d3773a/QM_Runs/getResultsofValidByUser?UserId=688078&pageIndex=1&pageSize=10 HTTP/1.1
 {"Success":true,"RaceNums":15,"RaceMNums":5,"AllCount":44,"LastPage":false,"listValue":[{"CostTime":"00时14分53秒","CostDistance":2001.0,"AvaLengths":2000.0,"ResultDate":"2021年03月15日","ResultHour":16,"StepNum":2186,"NoCountReason":null,"Speed":2.24},{"CostTime":"00时11分14秒","CostDistance":2002.0,"AvaLengths":2000.0,"ResultDate":"2021年03月14日","ResultHour":16,"StepNum":1572,"NoCountReason":null,"Speed":2.97},{"CostTime":"00时07分53秒","CostDistance":2001.0,"AvaLengths":2000.0,"ResultDate":"2021年03月13日","ResultHour":16,"StepNum":2204,"NoCountReason":null,"Speed":4.23},{"CostTime":"00时07分23秒","CostDistance":2002.0,"AvaLengths":2000.0,"ResultDate":"2021年03月12日","ResultHour":7,"StepNum":2034,"NoCountReason":null,"Speed":4.52},{"CostTime":"00时08分15秒","CostDistance":2002.0,"AvaLengths":2000.0,"ResultDate":"2021年03月11日","ResultHour":20,"StepNum":2199,"NoCountReason":null,"Speed":4.04},{"CostTime":"00时16分11秒","CostDistance":2002.0,"AvaLengths":2000.0,"ResultDate":"2021年03月10日","ResultHour":7,"StepNum":1666,"NoCountReason":null,"Speed":2.06},{"CostTime":"00时08分20秒","CostDistance":2001.0,"AvaLengths":2000.0,"ResultDate":"2021年03月09日","ResultHour":7,"StepNum":1747,"NoCountReason":null,"Speed":4.00},{"CostTime":"00时07分47秒","CostDistance":2002.0,"AvaLengths":2000.0,"ResultDate":"2021年03月08日","ResultHour":16,"StepNum":1841,"NoCountReason":null,"Speed":4.29},{"CostTime":"00时07分33秒","CostDistance":2004.0,"AvaLengths":2000.0,"ResultDate":"2021年03月07日","ResultHour":22,"StepNum":1580,"NoCountReason":null,"Speed":4.42},{"CostTime":"00时13分44秒","CostDistance":2003.0,"AvaLengths":2000.0,"ResultDate":"2021年03月06日","ResultHour":22,"StepNum":1985,"NoCountReason":null,"Speed":2.43}]}
 
 
 GET /api/10001e245ab14834b04fa70ca4d3773a/QM_Runs/getResultsofInValidByUser?UserId=688078&pageIndex=1&pageSize=10 HTTP/1.1
 {"Success":true,"RaceNums":15,"RaceMNums":5,"AllCount":45,"LastPage":false,"listInValue":[{"CostTime":"00时14分56秒","CostDistance":2000.0,"AvaLengths":2000.0,"ResultDate":"2021年03月14日","ResultHour":9,"StepNum":1719,"NoCountReason":"0","Speed":2.2321428571428571428571428571},{"CostTime":"00时21分22秒","CostDistance":2000.0,"AvaLengths":2000.0,"ResultDate":"2021年03月14日","ResultHour":0,"StepNum":1807,"NoCountReason":"0","Speed":1.5600624024960998439937597504},{"CostTime":"00时06分08秒","CostDistance":2004.0,"AvaLengths":2000.0,"ResultDate":"2021年03月14日","ResultHour":13,"StepNum":1912,"NoCountReason":"0","Speed":5.4456521739130434782608695652},{"CostTime":"00时08分32秒","CostDistance":2000.0,"AvaLengths":2000.0,"ResultDate":"2021年03月14日","ResultHour":11,"StepNum":1710,"NoCountReason":"0","Speed":3.90625},{"CostTime":"00时08分23秒","CostDistance":2002.0,"AvaLengths":2000.0,"ResultDate":"2021年03月14日","ResultHour":11,"StepNum":2009,"NoCountReason":"0","Speed":3.9801192842942345924453280318},{"CostTime":"00时07分21秒","CostDistance":2001.0,"AvaLengths":2000.0,"ResultDate":"2021年03月13日","ResultHour":23,"StepNum":2137,"NoCountReason":"1","Speed":4.5374149659863945578231292517},{"CostTime":"00时06分53秒","CostDistance":2001.0,"AvaLengths":2000.0,"ResultDate":"2021年03月13日","ResultHour":23,"StepNum":1615,"NoCountReason":"1","Speed":4.8450363196125907990314769976},{"CostTime":"00时06分22秒","CostDistance":2003.0,"AvaLengths":2000.0,"ResultDate":"2021年03月13日","ResultHour":23,"StepNum":2010,"NoCountReason":"1","Speed":5.2434554973821989528795811518},{"CostTime":"00时15分01秒","CostDistance":2002.0,"AvaLengths":2000.0,"ResultDate":"2021年03月12日","ResultHour":15,"StepNum":1921,"NoCountReason":"1","Speed":2.221975582685904550499445061},{"CostTime":"00时07分24秒","CostDistance":2003.0,"AvaLengths":2000.0,"ResultDate":"2021年03月12日","ResultHour":23,"StepNum":1770,"NoCountReason":"1","Speed":4.5112612612612612612612612613}]}
 
 GET /api/10001e245ab14834b04fa70ca4d3773a/QM_Runs/SRS?S1=30.542078&S2=114.367611&S3=2000 HTTP/1.1
 {
 "Success": true,
 "Data": {
 "StartTime": "2021-03-15 18:52:38",
 "RunId": "3ed2e9e1a2304f51ace65f91479619d4",
 "FUserId": 0,
 "FieldId": 246,
 "Routes": "A0A0",
 "LifeValue": 0,
 "Powers": 0,
 "LenValue": 0.0,
 "Points": [
 {
 "PointNo": "A0",
 "Lat": 30.544811,
 "Lng": 114.366494,
 "Minor": 1
 },
 {
 "PointNo": "A0",
 "Lat": 30.544811,
 "Lng": 114.366494,
 "Minor": 1
 }
 ],
 "FiledName": "武汉大学环跑—风雨操场",
 "Area": "114.365282,30.545238;114.36653,30.54574;114.368246,30.545705;114.368821,30.54359;114.367402,30.542925;114.365875,30.5429",
 "SenseType": "0",
 "ImgUrl": "",
 "Major": 0
 }
 }
 
 
 GET /api/10001e245ab14834b04fa70ca4d3773a/QM_Runs/ES?S1=3ed2e9e1a2304f51ace65f91479619d4&S2=ud&S3=p&S4=ud&S5=p&S6=&S7=0&S8=phulmfdvoq&S9=p HTTP/1.1
 {
 "Success": true,
 "Data": "success"
 }
 
 
 GET /api/token/QM_Users/LoginSchool?IMEICode=5801a078a9ef43c395901806c51a729b HTTP/1.1
 {
 "Success": true,
 "Data": {
 "Token": "2b64f8ce4c6147a092c52b8c6708f5a5",
 "UserId": 688078,
 "IMEICode": "5801a078a9ef43c395901806c51a729b",
 "AndroidVer": 2.1,
 "AppleVer": 1.24,
 "WinVer": 1.0
 }
 }
 
 
 https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=wx668004190386482e&secret=28665697e6d04ac8c78332cfecbc91f5
 */


import Alamofire

let BASE_URL_4 = "https://client4.aipao.me/api"
let BASE_URL_3 = "http://client3.aipao.me/api"

let manager = ServerTrustManager(evaluators: ["client4.aipao.me": DisabledTrustEvaluator()])
let session = Session(serverTrustManager: manager)

//登录用client4，其它用clinet3
let LOGIN_URI = "/token/QM_Users/LoginSchool?IMEICode="
func getValidResult(token: String, userId: String, pageNum: Int, pageSize: Int) {
    
    let url = URL(string: "\(BASE_URL_3)/\(token)/QM_Runs/getResultsofValidByUser?UserId=\(userId)&pageIndex=\(pageNum)&pageSize=\(pageSize)")
    session.request(url!, method: .get).responseJSON {response in
        print("RESPONSE: \(response)")
    }
}


getValidResult(token: "12376859405849384858697089786857", userId: "4758695", pageNum: 1, pageSize: 10)


