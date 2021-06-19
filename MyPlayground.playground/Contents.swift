import UIKit

var greeting = "Hello, playground"
func getDateString(isTomorrow: Bool) -> String{
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-M-dd"
    formatter.timeZone = TimeZone.init(secondsFromGMT: 0)
    
    var date: Date = Date()
    if isTomorrow {
        date.addTimeInterval(24 * 60 * 60)
    }
    let str = formatter.string(from: date)
    print(str)
    return str
}

print("12")
print(getDateString(isTomorrow: false))
